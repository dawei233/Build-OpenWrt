#/bin/bash
TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
echo
echo
TIME z "|*******************************************|"
TIME g "|                                           |"
TIME r "|     本脚本仅适用于在Ubuntu环境下编译      |"
TIME g "|                                           |"
TIME y "|    首次编译,请输入Ubuntu密码继续下一步    |"
TIME g "|                                           |"
TIME g "|*******************************************|"
echo
echo
sleep 2s

sudo apt-get update -y
sudo apt-get full-upgrade -y
sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync

clear
echo
echo
TIME g "|*******************************************|"
TIME z "|                                           |"
TIME z "|                                           |"
TIME y "|           基本环境部署完成......          |"
TIME z "|                                           |"
TIME z "|                                           |"
TIME z "|*******************************************|"
echo
echo


if [ "$USER" == "root" ]; then
	echo
	echo
	TIME g "请勿使用root用户编译，换一个普通用户吧~~"
	sleep 3s
	exit 0
fi
df -h
Ubuntu_lv="$(df -h | grep "/dev/mapper/ubuntu--vg-ubuntu--lv" | awk '{print $4}' | awk 'NR==1')"
echo "${Ubuntu_lv}" > pack
CURRENT_Version="$(awk 'NR==1' pack)"
CURRENT_Ver="60G"
if [[ "60" -lt "40" ]];then
	TIME && read -p "是否增删插件? [y/N]: " YN
	case ${YN:-N} in
		[Yy])
			echo ""
			break
		;;
		[Nn]) 
			echo ""
			TIME y "取消增删插件,继续编译固件..."
			exit 0
		;;
	esac
fi

rm -Rf openwrt

TIME g "1. Lede_source"
echo
TIME z "2. Lienol_source"
echo
TIME g "3. Project_source"
echo
TIME y "4. Spirit_source"
echo
TIME r "5. Exit"
echo
echo

while :; do

TIME && read -p "你想要编译哪个源码？请在1-4选择回车,选择5回车为退出！ " CHOOSE

case $CHOOSE in
	1)
		firmware="Lede_source"
	break
	;;
	2)
		firmware="Lienol_source"
	break
	;;
	3)
		firmware="Project_source"
	break
	;;
	4)
		firmware="Spirit_source"
	break
	;;
	5)	exit 0
	;;

esac
done
echo
echo
TIME && read -p "请输入您的github地址: " Github
Github=${Github:-"https://github.com/281677160/AutoBuild-OpenWrt"}
echo
TIME y "您的Github地址为: $Github"
echo
echo
Apidz="${Github##*com/}"
Author="${Apidz%/*}"
CangKu="${Apidz##*/}"
TIME g "正在下载源码中,请耐心等候~~~"
echo
if [[ $firmware == "Lede_source" ]]; then
          git clone -b master --single-branch https://github.com/coolsnowwolf/lede openwrt
	  ZZZ="package/lean/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
elif [[ $firmware == "Lienol_source" ]]; then
          git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
	  ZZZ="package/default-settings/files/zzz-default-settings"
          OpenWrt_name="19.07"
elif [[ $firmware == "Project_source" ]]; then
          git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
elif [[ $firmware == "Spirit_source" ]]; then
          git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="21.02"
fi

cp -Rf AutoBuild-OpenWrt/build openwrt/build
git clone --depth 1 -b main https://github.com/281677160/common openwrt/build/common
chmod -R +x openwrt/build/common
chmod -R +x openwrt/build/${firmware}
source openwrt/build/${firmware}/settings.ini

Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"

rm -rf AutoBuild-OpenWrt
mv -f openwrt/build/common/Convert.sh openwrt
mv -f openwrt/build/common/*.sh openwrt/build/${firmware}
echo
TIME g "正在加载自定义文件,请耐心等候~~~"
echo
cd openwrt
./scripts/feeds clean && ./scripts/feeds update -a
if [[ "${REPO_BRANCH}" == "master" ]]; then
          source build/${firmware}/common.sh && Diy_lede
          cp -Rf build/common/LEDE/files ./
          cp -Rf build/common/LEDE/diy/* ./
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
          source build/${firmware}/common.sh && Diy_lienol
          cp -Rf build/common/LIENOL/files ./
          cp -Rf build/common/LIENOL/diy/* ./
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
          source build/${firmware}/common.sh && Diy_1806
          cp -Rf build/common/PROJECT/files ./
          cp -Rf build/common/PROJECT/diy/* ./
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
          source build/${firmware}/common.sh && Diy_2102
          cp -Rf build/common/SPIRIT/files ./
          cp -Rf build/common/SPIRIT/diy/* ./
fi
source build/$firmware/common.sh && Diy_all
if [ -n "$(ls -A "build/$firmware/diy" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/diy/* ./
fi
if [ -n "$(ls -A "build/$firmware/files" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/files ./ && chmod -R +x files
fi
if [ -n "$(ls -A "build/$firmware/patches" 2>/dev/null)" ]; then
          find "build/$firmware/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward"
fi
if [[ "${REPO_BRANCH}" =~ (21.02|openwrt-21.02) ]]; then
          source Convert.sh
fi
echo
TIME g "正在加载源和安装源,请耐心等候~~~"
echo
source build/$firmware/$DIY_PART_SH
./scripts/feeds update -a && ./scripts/feeds install -a
[ -e build/$firmware/$CONFIG_FILE ] && mv build/$firmware/$CONFIG_FILE .config
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
          echo "Compile_Date=$(date +%Y%m%d%H%M)" > Openwrt.info
	  source build/$firmware/upgrade.sh && Diy_Part1
fi
echo
echo
while :; do
TIME && read -p "是否增删插件? [y/N]: " YN
case ${YN:-N} in
	[Yy])
		make menuconfig
		break
	;;
	[Nn]) 
		echo ""
		TIME y "取消增删插件,继续编译固件..."
		break
	;;
esac
done
echo
echo
make defconfig
if [ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]; then
          echo "x86-64" > DEVICE_NAME
          [ -s DEVICE_NAME ] && TARGET_PROFILE="$(cat DEVICE_NAME)"
elif [ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]; then
          grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
          [ -s DEVICE_NAME ] && TARGET_PROFILE="$(cat DEVICE_NAME)"
else
          TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
echo
echo
TIME y "*****10秒后开始编译*****"
echo
TIME g "你可以随时按Ctrl+C停止编译"
echo
TIME z "大陆用户编译前请准备好梯子,使用大陆白名单或全局模式"
echo
echo
sleep 8s
TIME g "正在下载插件包"
make download -j8
echo
TIME g "开始编译固件,时间有点长,请耐心等待..."
echo
echo -e "$(($(nproc)+1)) thread compile"
make -j$(($(nproc)+1)) || make -j1 V=s

if [ "$?" == "0" ]; then
TIME y "
编译完成~~~
初始用户名密码: root  root
"
fi
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source build/${firmware}/upgrade.sh && Diy_Part3
fi