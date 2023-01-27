#!/bin/bash
#####################################################
#Author:wang
#name:HomeAssistant_installation
#Function:home-assistant及插件一键安装脚本
#Version:1.0
#####################################################

function depandence(){
		echo -n "正在安装依赖"
		apt-get install \
jq \
wget \
curl \
udisks2 \
libglib2.0-bin \
network-manager \
dbus -y
		echo -n "安装依赖完成"
		
		echo -n "正在安装app armor"
		apt install apparmor
		echo -n "安装app armor完成"
	return $?
}

function installdocker(){
		echo -n "正在安装docker"
		curl -fsSL get.docker.com | sh
		echo -n "安装docker完成"
	return $?
}

function downloadfiles(){
		echo -n "正在下载所需文件"
		wget https://github.com/home-assistant/os-agent/releases/download/1.2.2/os-agent_1.2.2_linux_aarch64.deb
		wget https://github.com/home-assistant/supervised-installer/releases/download/1.0.2/homeassistant-supervised.deb
		echo -n "下载所需文件完成"
	return $?
}

function installation(){
		echo -n "正在安装osagent"
		dpkg -i os-agent_1.2.2_linux_aarch64.deb
		echo -n "安装osagent完成"

		echo -n "正在安装homeassistant supervised"
		dpkg -i homeassistant-supervised.deb
		echo -n "安装homeassistant supervised完成"
		
	return $?
}

function installplugin(){
		echo -n "安装hacs"
		mkdir /usr/share/hassio/homeassistant/custom_components
		wget https://github.com/hacs/integration/releases/download/1.30.1/hacs.zip
		unzip -d /usr/share/hassio/homeassistant/custom_components/hacs hacs.zip
		echo -n "安装miot"
		wget https://github.com/al-one/hass-xiaomi-miot/releases/download/v0.7.5/xiaomi_miot.zip
		unzip -d /usr/share/hassio/homeassistant/custom_components/xiaomi_miot xiaomi_miot.zip
	return $?
}

function installsshwifty(){
		echo -n "正在创建证书"
		openssl req \
  -newkey rsa:4096 -nodes -keyout domain.key -x509 -days 1095 -out domain.crt
		echo -n "正在创建docker容器"
		docker run --detach \
  --restart always \
  --publish 8182:8182 \
  --env SSHWIFTY_DOCKER_TLSCERT="$(cat domain.crt)" \
  --env SSHWIFTY_DOCKER_TLSCERTKEY="$(cat domain.key)" \
  --name sshwifty \
  niruix/sshwifty:latest
		
	return $?
}

function installavachi(){
		echo -n "正在安装avachi"
		apt-get install avahi-daemon -y
		echo -n "开启avachi"
		systemctl start avahi-daemon.service
		echo -n "正在更改hostname"
		hostnamectl set-hostname hassbox
	return $?
}

depandence
installdocker
downloadfiles
installation
installplugin
installsshwifty
installavachi
sleep 1
echo -n "========================="
echo -n "success!"
echo -n "========================="
