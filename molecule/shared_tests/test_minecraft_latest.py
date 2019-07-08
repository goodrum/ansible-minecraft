import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_minecraft_group(host):
    assert host.group("minecraft")


def test_minecraft_user(host):
    assert host.user("minecraft")


def test_minecraft_install_directory(host):
    minecraft = host.file("/srv/minecraft")
    assert minecraft.exists
    assert minecraft.is_directory
    assert minecraft.user == "minecraft"
    assert minecraft.group == "minecraft"


def test_minecraft_versionless_executable(host):
    minecraft = host.file("/srv/minecraft/minecraft_server.jar")
    assert minecraft.exists
    assert minecraft.is_symlink
    assert minecraft.user == "minecraft"
    assert minecraft.group == "minecraft"


def test_minecraft_eula(host):
    minecraft = host.file("/srv/minecraft/eula.txt")
    assert minecraft.exists
    assert minecraft.content == "eula=true\n"


def test_minecraft_service_running_and_enabled(host):
    minecraft = host.service("minecraft.service")
    assert minecraft.is_running
    assert minecraft.is_enabled


def test_minecraft_socket_running_and_enabled(host):
    minecraft = host.service("minecraft.socket")
    assert minecraft.is_running
    assert minecraft.is_enabled


def test_minecraft_service_listening(host):
    assert host.socket("tcp://0.0.0.0:25565").is_listening


def test_minecraft_rcon_listening(host):
    assert host.socket("tcp://0.0.0.0:25564").is_listening
