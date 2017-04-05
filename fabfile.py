# -*- coding: utf-8 -*-
import sys
import yaml
import os
from fabric.api import cd, env, run, task, require, sudo, local
from fabric.colors import green, red, white, yellow, blue
from fabric.contrib.console import confirm
from fabric.contrib.files import exists
from fabric.operations import get
from fabric import state
from fabutils import boolean

from fabutils.env import set_env_from_json_file
from fabutils.tasks import ursync_project, ulocal, urun
from os.path import join, dirname
from dotenv import load_dotenv # python-dotenv

env.is_docker = True
env.confirm_task = True
def load_docker_dotenv():
    """
    Load dot env vars.
    """
    dotenv_path = join(dirname(__file__), '.env')
    load_dotenv(dotenv_path)
    env.project_type = os.environ.get("PROJECT_TYPE")
    env.project_name = os.environ.get("PROJECT_NAME")
    env.public_dir = os.environ.get("PROJECT_ROOT")
    env.dbname = os.environ.get("DB_NAME")
    env.dbuser = os.environ.get("DB_USERNAME")
    env.dbpassword = os.environ.get("DB_PASSWORD")
    env.dbhost = os.environ.get("DB_HOST")


def load_settings_env(env_name):
    """
    Load settings yaml file env vars.
    """
    with open("settings.yaml", 'r') as stream:
        try:
            settings = yaml.load(stream)
            env.user =  settings[env_name]['user']
            env.group =  settings[env_name]['group']
            env.host =  settings[env_name]['hosts']
            env.public_dir =  settings[env_name]['public_dir']
            env.dbname =  settings[env_name]['dbname']
            env.dbuser = settings[env_name]['dbuser']
            env.dbpassword = settings[env_name]['dbpassword']
            env.dbhost = settings[env_name]['dbhost']
        except yaml.YAMLError as exc:
            print(exc)


load_docker_dotenv()
@task
def environment(env_name, debug=False):
    """
    Creates the configurations for the environment in which tasks will run.
    """
    env.env_name = env_name
    state.output['running'] = boolean(debug)
    state.output['stdout'] = boolean(debug)
    print "Establishing environment " + blue(env_name, bold=True) + "..."

    if env_name == 'docker':
        load_docker_dotenv()
    else:
        env.is_docker = False
        load_settings_env(env_name)


@task
def up():
    """
    Start docker containers.
    """
    print "Creating local environment."
    result = local('docker-compose up -d')


@task
def stop():
    """
    Stop docker containers.
    """
    print "Creating local environment."
    result = local('docker-compose stop')


@task
def down():
    """
    Destroys docker containers and volumes.
    """
    print "Creating local environment."
    result = local('docker-compose down -v')


@task
def bluid():
    """
    Bluid docker compose with out cache.
    """
    print "Creating local environment."
    result = local('docker-compose build --no-cache')


@task
def import_sql(file_name="dump.sql"):
    """
    Imports the database to given file name. database/data.sql by default.
    """
    require('dbuser', 'dbpassword', 'dbhost')
    confirm_task()

    env.file_name = file_name

    if env.is_docker:
        print "Importing data from file: " + blue(file_name, bold=True) + "..."
        local(
            """
            docker exec -i {project_name}_db mysql -u'{dbuser}' -p'{dbpassword}' {dbname}\
            < ../database/{file_name}
            """.format(**env)
        )
    else:
        print "Importing data from file: " + blue(file_name, bold=True) + "..."
        run("""
            mysql -u'{dbuser}' -p'{dbpassword}' {dbname} --host={dbhost} <\
            ~/database/{file_name} """.format(**env))


@task
def dumpdb(file_name="dump.sql", just_data=False, confirm_overwriting=True):
    """
    Exports the database to given file name. database/dump.sql by default.
    """
    if env.is_docker:
        require('project_name', 'dbuser', 'dbpassword', 'dbname')
        export = True
        env.file_name = file_name

        if boolean(just_data):
            env.just_data = "--no-create-info"
        else:
            env.just_data = " "

        if export:
            print "Exporting data to file: " + blue(file_name, bold=True) + "..."
            local(
                """
                docker exec {project_name}_db mysqldump -u {dbuser} -p'{dbpassword}' {dbname}\
                {just_data} > ../database/{file_name}
                """.format(**env)
            )
        else:
            print 'Export canceled by user'
            sys.exit(0)
    else:
        require('public_dir', 'dbuser', 'dbpassword', 'dbname', 'dbhost')
        export = True
        env.file_name = file_name

        if boolean(just_data):
            env.just_data = "--no-create-info"
        else:
            env.just_data = " "

            sys.exit(0)
        if not exists('~/database/'):
            run('mkdir ~/database/')

        if boolean(confirm_overwriting):
            if exists('~/database/{file_name}'.format(**env)):
                export = confirm(
                    yellow(
                        '~/database/{file_name} '.format(**env)
                        +
                        'already exists, Do you want to overwrite it?'
                    )
                )

        if export:
            if is_docker:
                print "Exporting data to file: " + blue(file_name, bold=True) + "..."
                local(
                    """
                    docker exec {project_name}_db mysqldump -u {dbuser} -p'{dbpassword}' {dbname}\
                    {just_data} > ~/database/{file_name}
                    """.format(**env)
                )
            else:
                print "Exporting data to file: " + blue(file_name, bold=True) + "..."
                run(
                    """
                    mysqldump -u {dbuser} -p'{dbpassword}' {dbname} --host={dbhost}\
                    {just_data} > ~/database/{file_name}
                    """.format(**env)
                )
        else:
            print 'Export canceled by user'
            sys.exit(0)


@task
def resetdb():
    """
    Drops the database and recreate it.
    """
    require('dbname', 'dbuser', 'dbpassword', 'dbhost')
    confirm_task()
    if env.is_docker:
        print "Dropping database..."
        local(
            """
            docker exec -i {project_name}_db mysql -u'{dbuser}' -p'{dbpassword}'\
            -e "DROP DATABASE IF EXISTS {dbname}; CREATE DATABASE {dbname}"
            """.format(**env)
        )
    else:
        print "Dropping database..."
        run("""
            echo "DROP DATABASE IF EXISTS {dbname};
            CREATE DATABASE {dbname};
            "|mysql --batch --user={dbuser} --password='{dbpassword}' --host={dbhost}
            """.format(**env))


@task
def drop_tables():
    """
    Drops all tables from database without delete database.
    This command is not supported for docker.
    """
    require('dbname', 'dbuser', 'dbpassword', 'dbhost')
    if env.is_docker:
        print yellow("This command is not supported for docker environment.")
        exit(0)
    confirm_task()
    print "Dropping tables..."
    run("""
        (echo 'SET foreign_key_checks = 0;';
        (mysqldump -u{dbuser} -p'{dbpassword}' --add-drop-table --no-data {dbname} | grep ^DROP);
        echo 'SET foreign_key_checks = 1;') | \\
        mysql --user={dbuser} --password='{dbpassword}' -b {dbname} --host={dbhost}
        """.format(**env))


@task
def deploy(delete=False):
    """
    Sync modified files in selected environment.
    """
    require('group', 'public_dir', 'src', 'exclude')

    print white("Uploading code to server...", bold=True)
    ursync_project(
        local_dir="'./{src}/'".format(**env),
        remote_dir=env.public_dir,
        exclude=env.exclude,
        delete=delete,
        default_opts='-chrtvzP'
    )

    print green(u'Successfully sync.')


@task
def backup(tarball_name='backup', just_data=False):
    """
    Generates a backup copy of database
    """
    require('public_dir')

    env.tarball_name = tarball_name

    export_data(tarball_name + '.sql', just_data)

    print 'Preparing backup directory...'

    if not os.path.exists('./backup/'):
        os.makedirs('./backup/')

    if exists('{public_dir}backup/'):
        run('rm -rf {public_dir}backup/')

    if not exists('{public_dir}backup/'.format(**env)):
        run('mkdir {public_dir}backup/'.format(**env))

    if not exists('{public_dir}backup/database/'.format(**env)):
        run('mkdir {public_dir}backup/database/'.format(**env))

    run(
        'mv ~/database/{tarball_name}.sql '.format(**env)
        +
        '{public_dir}/backup/database/'.format(**env)
    )

    print 'Creating tarball...'
    with cd(env.public_dir):
        urun('tar -czf {tarball_name}.tar.gz backup/*'.format(**env))

    print 'Downloading backup...'
    download = True
    if os.path.exists('./backup/{tarball_name}.tar.gz'.format(**env)):
        download = confirm(
            yellow(
                './backup/{tarball_name}.tar.gz'.format(**env)
                +
                ' already exists, Do you want to overwrite it?'
            )
        )

    if download:
        get(
            '{public_dir}{tarball_name}.tar.gz'.format(**env),
            './backup/{tarball_name}.tar.gz'.format(**env)
        )
    else:
        print red('Backup canceled by user')

    print 'Cleaning working directory...'
    run('rm -rf {public_dir}backup/'.format(**env))
    run('rm {public_dir}{tarball_name}.tar.gz'.format(**env))

    if download:
        print green(
            'Backup succesfully created at'
            +
            ' ./backup/{tarball_name}.tar.gz'.  format(**env)
        )


@task
def execute(command=""):
    """
    Execute command bash into environment.
    """
    env.command = command
    state.output['stdout'] = True
    with cd('{public_dir}'.format(**env)):
        run('{command}'.format(**env))


@task
def it(container_name=""):
    """
    Runs an iterative terminal for a container.
    """
    env.container_name = container_name
    state.output['stdout'] = True
    local("""docker exec -it {container_name} bash""".format(**env))


@task
def logs(container_name=""):
    """
    Show logs from container.
    """
    env.container_name = container_name
    state.output['stdout'] = True
    local("""docker logs -f {container_name}""".format(**env))


def confirm_task(error_message = "Environment is not equals"):
    if not env.is_docker and env.confirm_task :
        env_name = raw_input("Confirm environment:")
        if env.env_name != env_name :
            print error_message
            sys.exit(0)
        else:
            env.confirm_task = False
