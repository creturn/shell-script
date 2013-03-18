#!/bin/sh
echo "server config settings"
echo "========================================"
read -p "set server SN:" sn
read -p "set server Num:" num
read -p "set server domain:" domain
read -p "set server tel_wan_ip:" telip
read -p "set server net_wan_ip:" netip
read -p "set server db_lan_ip:" dbip
read -p "set server erlang_lan_ip:" erlip
read -p "set server cookie:" cookie
if [ "$sn" = "0" ]
then
sn=""
fi
if [ "$num" = "0" ]
then
num=""
fi
cd /svn/erlangBen/sh
rm -rf bak_*
if [ -e gateway${num}.sh ]
then
mv gateway${num}.sh bak_gateway${num}.sh
fi
cat >gateway${num}.sh <<eof
#!/bin/sh

NODE=0
COOKIE=hsxy$cookie
NODE_NAME=hsxy${num}_gateway@${erlip}

ulimit -SHn 102400

# define default configuration
POLL=true
SMP=auto
ERL_MAX_PORTS=32000
ERL_PROCESSES=500000
ERL_MAX_ETS_TABLES=1400

export ERL_MAX_PORTS
export ERL_MAX_ETS_TABLES

DATETIME=\`date "+%Y%m%d%H%M%S"\` 
LOG_PATH="../logs/app_gw${num}.\$DATETIME.log" 

cd ../config
erl +P \$ERL_PROCESSES \\
	+K \$POLL \\
	-smp \$SMP \\
	-pa ../ebin \\
	-name \$NODE_NAME \\
	-setcookie \$COOKIE \\
	-boot start_sasl \\
	-kernel inet_dist_listen_min 9001 inet_dist_listen_max 9009 \\
	-kernel error_logger \{file,\"\$LOG_PATH\"\} \\
	-config gateway${num} \\
	-s yg gateway_start
eof

tepi=0
while [ ${tepi} -lt 8 ] 
do
tepi=`expr ${tepi} + 1` 
if [ -e run${num}_0${tepi}.sh ]
then
mv run${num}_0${tepi}.sh bak_run${num}_0${tepi}.sh
fi
cat >run${num}_0${tepi}.sh <<eof
#!/bin/sh

NODE=0${tepi}
COOKIE=hsxy$cookie
NODE_NAME=hsxy${num}_game\$NODE@${erlip}

ulimit -SHn 102400

# define default configuration
POLL=true
SMP=auto
ERL_MAX_PORTS=32000
ERL_PROCESSES=500000
ERL_MAX_ETS_TABLES=1400

export ERL_MAX_PORTS
export ERL_MAX_ETS_TABLES

DATETIME=\`date "+%Y%m%d%H%M%S"\` 
LOG_PATH="../logs/app_${num}_\$NODE.\$DATETIME.log" 

cd ../config
	erl +P \$ERL_PROCESSES \\
	+K \$POLL \\
	-smp \$SMP \\
	-pa ../ebin \\
	-name \$NODE_NAME \\
	-setcookie \$COOKIE \\
	-boot start_sasl \\
	-config run${num}_\$NODE \\
	-kernel error_logger \{file,\"\$LOG_PATH\"\} \\
	-s yg server_start

eof
done 


cd /svn/erlangBen/config
rm -rf bak_*
if [ -e gateway${num}.config ]
then
mv gateway${num}.config bak_gateway${num}.config
fi
cat >gateway${num}.config <<eof
[
  {sasl, [   
    	{sasl_error_logger, false},    
    	{errlog_type, error},   
    	{error_logger_mf_dir, "./logs"},     %% dirs
    	{error_logger_mf_maxbytes, 1048760}, %% 10M per log file.   
    	{error_logger_mf_maxfiles, 10}       %% maxinum number of 10
    	]
   },
   
  {gateway, [
  		{tcp_listener_ip,[
						{ip, "$domain"}
						]},
		{tcp_listener,[
						{port, ${num+8}777}, 
						{node_id, 0},
						{acceptor_num, 100},
						{max_connections, 3000}
						]},
		{mysql_config, 	  [
						{host, "127.0.0.1"},
						{port, 3306}, 
						{user, "root"},
						{password, "root"},
						{db, "zttx_dev"},
						{encode, utf8}
				  		]},
		{emongo_config, [
						{poolId,"master_mongo"},
						{emongoHost, "$dbip"},
						{emongoPort, 27017},
						{emongoDatabase, "zttx_dev${num}"},
						{emongoSize, 1}
						]},	
		{log_emongo_config, [
						{poolId,"log_mongo"},
						{emongoHost, "$dbip"},
						{emongoPort, 27017},
						{emongoDatabase, "zttx_dev${num}"},
						{emongoSize, 1}
						]},
		{slave_emongo_config, [
						{poolId,"slave_mongo"},
						{emongoHost, "$dbip"},
						{emongoPort, 27017},
						{emongoDatabase, "zttx_dev${num}"},
						{emongoSize, 1}
						]},				  		
		{log_level, 3},				%% 日志输出级别类型
		{http_ips, ["127.0.0.1","${erlip}","${telip}","${netip}"]},
		{base_data_from_db, 1},		%% 基本数据实时读数据库？(1：是，使用ets; 0：否，来自生成的静态文件)
		{gateway_async_time,10}              %% 延时允许客户端连接 单位：秒
		]
  }
]. 
eof


tepii=0
while [ $tepii -lt 8 ] 
do
tepii=`expr ${tepii} + 1` 
if [ -e run${num}_0${tepii}.config ]
then
mv run${num}_0${tepii}.config bak_run${num}_0${tepii}.config
fi
cat >run${num}_0${tepii}.config <<eof
[
  {sasl, [   
    	{sasl_error_logger, false},     
    	{errlog_type, error},   
    	{error_logger_mf_dir, "./logs"},     %% dirs
    	{error_logger_mf_maxbytes, 1048760}, %% 10M per log file.   
    	{error_logger_mf_maxfiles, 10}       %% maxinum number of 10
    	]
   },
  
  {server, [  
  		{tcp_listener_ip,[
						{ip, "$domain"}
						]},
		{tcp_listener,[
						{port, ${num+8}76${tepii}}, 
						{node_id, 0${tepii}},
						{acceptor_num, 100},
						{max_connections, 3000}
						]},
		{mysql_config, 	  [
						{host, "127.0.0.1"},
						{port, 3306}, 
						{user, "root"},
						{password, "root"},
						{db, "zttx_dev"},
						{encode, utf8}
				  		]},
		{emongo_config, [
						{poolId,"master_mongo"},
						{emongoHost, "$dbip"},
						{emongoPort, 27017},
						{emongoDatabase, "zttx_dev${num}"},
						{emongoSize, 1}
						]},	
		{log_emongo_config, [
						{poolId,"log_mongo"},
						{emongoHost, "$dbip"},
						{emongoPort, 27017},
						{emongoDatabase, "zttx_dev${num}"},
						{emongoSize, 1}
						]},
		{slave_emongo_config, [
						{poolId,"slave_mongo"},
						{emongoHost, "$dbip"},
						{emongoPort, 27017},
						{emongoDatabase, "zttx_dev${num}"},
						{emongoSize, 1}
						]},				  		
		{gateway_node, 'hsxy_gateway@${erlip}'},	%% 网关节点	
		{log_level, 3},				%% 日志输出级别类型
		{base_data_from_db, 1},		%% 基本数据实时读数据库？(1：是，使用ets; 0：否，来自生成的静态文件)
		{scene_here, []},			%% 开启加载在本节点场景(all--所有非副本节点; [100]--配置的节点)
		{guest_account_url, "http://www.xfj.com/guest_account.php"},		%% 获取游客账号Url
		{can_gmcmd, 0},				%% GM命令启用否 （1：开启; 0: 关闭）
		{strict_md5, 0},			%% 是否需要严格验证 （1：验证; 0: 不验证）
		{infant_ctrl, 0}			%% 防沉迷系统开关 （1：开启; 0: 关闭）
		]
  }
]. 
eof
done

cd /svn/erlangBen/sh
cat >db_backup.sh <<eof
#!/bin/sh
DATETIME=\`date "+%Y%m%d_%H"\`
cd /data/mongodb/bin
./mongodump
sleep 60s
echo "mongodb backup finished."
cd /home/backup/
mkdir hsxy_db_\$DATETIME
cd /data/mongodb/bin/dump
mv * /home/backup/hsxy_db_\$DATETIME
echo "mongodb to backup."
eof

cat >db_clear.sh <<eof
#!/bin/sh
NODE="$erlip"
DATETIME=\`date +%Y%m%d -d '1 days ago'\` 
DATE=\`date +%Y%m%d\`
cd /home/log/
tar -zcvf sys_log_"\$NODE"_"\$DATE".tar.gz . >/dev/null 2>&1
mv sys_log_"\$NODE"_"\$DATE".tar.gz /svn/log/
rm -rf /home/log/*
echo "system log backup finished."
if [ -e /svn/log/erlang_log.tar.gz ]
then
mv /svn/log/erlang_log.tar.gz /svn/log/erl_log_"\$NODE"_"\$DATE".tar.gz
echo "erlang log backup finished."
cd /svn/log/
/usr/local/bin/svn add erl_log_"\$NODE"_"\$DATE".tar.gz
/usr/local/bin/svn add sys_log_"\$NODE"_"\$DATE".tar.gz
else
cd /svn/log/
/usr/local/bin/svn add sys_log_"\$NODE"_"\$DATE".tar.gz
fi
if [ -e /data/log/monit.log ]
then
cd /svn/log
cp /data/log/monit.log monit_"\$NODE"_"\$DATE".log
/usr/local/bin/svn add monit_"\$NODE"_"\$DATE".log
>/data/log/monit.log
echo "monit logs import finished"
fi
/usr/local/bin/svn commit -m log_bak_"\$DATE"
echo "logs import finished."
if [ -e /home/backup/hsxy_db_\$DATETIME"_04" ]
then
cd /home/backup
mv hsxy_db_\$DATETIME"_04" hsxy_bck_"\$DATETIME"
rm -rf hsxy_db_"\$DATETIME"*
echo "mongodb cleared."
fi
eof

cat >db_convert.sh <<eofi
#!/bin/sh
read -p "input convert server num:" cnum
mysql -h localhost -u root -p zttx_dev\${cnum} <"/svn/erlangBen/zttx_dev.sql"
sh gateway\${cnum}.sh <<eof
mysql_to_emongo:start_base().
eof
eofi

cat >db_update.sh <<eof
#!/bin/sh
svn up /svn/erlangBen/ebin
echo "ebin svn update finished."
svn up /svn/erlangBen/zttx_dev.sql
echo "zttx_dev.sql svn update finished."
svn up /svn/erlangBen/include
echo "include svn update finished."
eof

rm -rf start.sh
cat >start.sh <<eof
#!/bin/bash
/usr/sbin/ntpdate asia.pool.ntp.org
if [ -e /svn/log/erlang_log.tar.gz ]
then
echo "logs already exists."
else
cd /svn/erlangBen/logs/
tar -zcvf erlang_log.tar.gz . >/dev/null 2>&1
mv erlang_log.tar.gz /svn/log/
rm -rf /svn/erlangBen/logs/*
echo "logs backup finished."
fi
cd /svn/erlangBen/sh
read -p "input start server num:" snum
if [ "$snum" = "0" ]
then
snum=""
fi
sleep 1s
screen -dmS gateway\${snum} sh gateway\${snum}.sh
sleep 5s
echo "gateway\${snum} started."
screen -dmS run\${snum}_01 sh run\${snum}_01.sh
sleep 5s
echo "run\${snum}_01 started."
screen -dmS run\${snum}_02 sh run\${snum}_02.sh
sleep 5s
echo "run\${snum}_02 started."
screen -dmS run\${snum}_03 sh run\${snum}_03.sh
sleep 5s
echo "run\${snum}_03 started."
screen -dmS run\${snum}_04 sh run\${snum}_04.sh
sleep 5s
echo "run\${snum}_04 started."
screen -ls
echo "game start up finished."
eof


rm -rf ps_resources.sh
cat >ps_resources.sh <<eof
#!/bin/sh
date=\`date +%Y%m%d_%H\`
ps aux | grep beam > /home/log/Tem_sy.log
cat /home/log/Tem_sy.log >> /home/log/Resources_all.log
cpu=\`grep "bin/beam" /home/log/Tem_sy.log | gawk '{print \$3}'\`
echo "\$date   beam cpu used:                                      "\$cpu >> /home/log/Resources.log
mem=\`grep "bin/beam" /home/log/Tem_sy.log | gawk '{print \$4}'\`
echo "\$date   beam mem used:                                      "\$mem >> /home/log/Resources.log
echo ==============\$date beam record complete.=============== >> /home/log/Resources.log
ps aux | grep mongo > /home/log/Tem_db.log
cat /home/log/Tem_db.log >> /home/log/Resources_all.log
cpu=\`grep "bin/mongo" /home/log/Tem_db.log | gawk '{print \$3}'\`
echo "\$date   mongo cpu used:                                     "\$cpu >> /home/log/Resources.log
mem=\`grep "bin/mongo" /home/log/Tem_db.log | gawk '{print \$4}'\`
echo "\$date   mongo mem used:                                     "\$mem >> /home/log/Resources.log
echo ==============\$date mongo record complete.============== >> /home/log/Resources.log
df -lh > /home/log/Tem_hd.log
cat /home/log/Tem_hd.log >> /home/log/Resources_all.log
grep -q /home /home/log/Tem_hd.log
total=\`grep "/home" /home/log/Tem_hd.log | gawk '{print \$1}'\`
used=\`grep "/home" /home/log/Tem_hd.log | gawk '{print \$2}'\`
free=\`grep "/home" /home/log/Tem_hd.log | gawk '{print \$3}'\`
per=\`grep "/home" /home/log/Tem_hd.log | gawk '{print \$4}'\`
echo "\$date   hard total:  "\$total"   used:  "\$used"   free:  "\$free"   perc:  "\$per>> /home/log/Resources.log
echo ==============\$date disk record complete.=============== >> /home/log/Resources.log
echo >> /home/log/Resources.log
rm -rf /home/log/Tem_sy.log
rm -rf /home/log/Tem_db.log
rm -rf /home/log/Tem_hd.log
exit
eof



cd /svn/erlangBen/config
if [ -e gateway.app ]
then
echo "gateway.app already exists."
else
cat >gateway.app <<eof
{   
    application, gateway,
    [   
        {description, "This is game gateway."},   
        {vsn, "1.0a"},   
        {modules, [yg] },   
        {registered, [yg_gateway_sup]},   
        {applications, [kernel, stdlib, sasl]},   
        {mod, {yg_gateway_app, []}},   
        {start_phases, []}   
    ]   
}.    
 
%% File end.  
eof
fi



if [ -e server.app ]
then
echo "server.app already exists."
else
cat >server.app <<eof
{   
    application, server,
    [   
        {description, "This is game server."},   
        {vsn, "1.0a"},   
        {modules, [yg]},   
        {registered, [yg_server_sup]},   
        {applications, [kernel, stdlib, sasl]},   
        {mod, {yg_server_app, []}},   
        {start_phases, []}   
    ]   
}.    
 
%% File end.  
eof
fi

rm -rf /svn/www/html/ser_nginx.conf
cat >/svn/www/html/ser_nginx.conf <<eof

server
	{
		listen       80;
		server_name $domain;
		index index.html index.htm index.php;
		root  /svn/www/html;

		location ~ .*\\.(php|php5)?\$
			{
				fastcgi_pass 127.0.0.1:9000;
				fastcgi_index index.php;
				include fcgi.conf;
			}

		location /status {
			stub_status on;
			access_log   off;
		}

		location ~ .*\\.(gif|jpg|jpeg|png|bmp|swf)\$
			{
				expires      30d;
			}

		location ~ .*\\.(js|css)?\$
			{
				expires      12h;
			}
	}


eof


rm -rf /svn/www/html/flash/config.xml
cat >/svn/www/html/flash/config.xml <<eof
<?xml version="1.0" encoding="utf-8"?>
<xml>
	<version>v20120101</version>
	<!-- type 对应ip编号 相应人员一个编号-->
	<socket type="1">
		<ip>
			<item>$domain</item>
		</ip>
		<port>${num+8}777</port>  
		<sNum>5000</sNum>
	</socket>
	<website>
		<!-- 官网 -->
        <item name="mainWebSite"> 
			<![CDATA[ http://lm.7wan.com/hub/web.html?game=hsxy]]>
        </item>
        <!-- 充值 -->
        <item name="recharge">
            <![CDATA[ http://lm.7wan.com/hub/pay.html?game=hsxy]]>
        </item>
        <!-- 论坛 -->
        <item name="forum">
            <![CDATA[ http://lm.7wan.com/hub/bbs.html?game=hsxy]]>
        </item>
        <!-- 注册 -->
        <item name="register">
            <![CDATA[ http://lm.7wan.com/hub/fail.html?game=hsxy]]>
        </item>
        <!-- 新手卡 -->
        <item name="newGuy">
            <![CDATA[ http://lm.7wan.com/hub/newcard.html?game=hsxy]]>
        </item>
        <!-- 防沉迷 -->
        <item name="enthrallment">
            <![CDATA[ http://lm.7wan.com/hub/fail.html?game=hsxy]]>
        </item>
		<!-- 选服页 -->
		<item name="selectServer">
			<![CDATA[http://hsxy.7wan.com/select_server.html]]>
		</item>
		<!-- 绑定手机 -->
		<item name="bindPhone">
			<![CDATA[http://web.7wan.com/bind_phone.html]]>
		</item>
		<item name="exitGame">
			<![CDATA[http://web.7wan.com/hsxy]]>
		</item>
		<!-- 繁體版GM用鏈接 -->
		<item name="dl_gm">
			<![CDATA[http://lm.7wan.com/hub/bbs.html?game=hsxy]]>
		</item>
	</website>
	<!-- gm号配置 -->
	<gm>
		<item name="a"/>
	</gm>
	<guider>
		<item name="b"/>
	</guider>
	<file root="http://$domain/flash/">
	</file>
	<isTest value="0" /><!-- 1为真，属于测试状态，否则为0-->
	<enthrallment first="10000" second="0" />
	<platform name="HUNFU"/><!--DUOWAN-->
	<autoFull value="1" /><!-- 1为真，属于默认全屏状态，否则为0-->
	 
	<BlockWords isBlockTCWords="1" /><!-- 1为真，判断屏蔽詞，否则为0-->
</xml>
eof


rm -rf /svn/www/html/hsxymongo/config.php
cat >/svn/www/html/hsxymongo/config.php <<eof
<?php

//configure servers
\$MONGO = array();
\$MONGO["servers"] = array(
	array(
		"host" => "$dbip",//replace your MongoDB host ip or domain name here
		"port" => "27017",//MongoDB connection port
		"username" => null,//MongoDB connection username
		"password" => null,//MongoDB connection password
		"admins" => array( 
			"admin" => "cmwl_2011_db", //Administrator's USERNAME => PASSWORD
		)
	),
);

?>
eof



rm -rf /svn/www/html/define.php
cat >/svn/www/html/define.php <<eof
<?php
header("P3P:CP=CAO PSA OUR");
define("DEBUG",true);
//Report all errors directly to the screen for simple diagnostics in the dev environment
error_reporting(E_ALL ^ E_NOTICE);
ini_set("display_startup_errors", 1);
ini_set("display_errors", 1);
ini_set("magic_quotes_runtime", 0);
ini_set("session.cookie_httponly", 1);
/*服务器域名地址*/
\$server = \$_SERVER[""];
define("COOKIEDOMAIN",\$_SERVER["SERVER_NAME"]);
define("PUBLICWEBROOT","http://".\$_SERVER["SERVER_NAME"]."/");
//define("HOMEURL","http://www.zttx.com/");
define("HOMEURL", "http://".\$_SERVER["HTTP_HOST"]."/");
//游戏名
define("TITLE","幻世轩辕第$sn大区");

//管理员分组和菜单的同步服务器
define(SYNC_SERVER_URL,PUBLICWEBROOT."hs-cm/sync.php");

//服务器编号
define("GAMESERVER_NUM","S$sn");

//TICKET
define("TICKET_SUBFIX", "SDFSDESF123DFSDF");

//MD5KEY
define("MD5KEY","vXDKCbm*dwZb+D+*JhMXU%+o7wan");

//官网地址
define("OFFICEURL","http://lm.7wan.com/hub/web.html?game=hsxy");

//论坛地址
define("OFFICEBBS","http://lm.7wan.com/hub/bbs.html?game=hsxy");

//新手卡领取地址
define("NEWCARD","http://lm.7wan.com/hub/newcard.html?game=hsxy");

//充值地址
define("PAYURL","http://lm.7wan.com/hub/pay.html?game=hsxy".GAMESERVER_NUM);

//游客模式地址
define("GUESTHOST","http://www.7wan.com/");

//游戏程序网关IP
//define("GAME_IP", \$_SERVER["HTTP_HOST"]);
define("GAME_IP", "127.0.0.1");

//游戏程序网关对外开放端口
define("GAME_PORT", ${num+8}777);

//收藏夹名称 为空则为当前浏览器标题
define("FAVOURITENAME","");
//收藏链 为空则当前浏览器地址
define("FAVOURITEURL","");

//兑换率
define("SERVER_RATE", 10);

//是否开启顶部导航 子导航
define("SHOW_TOP_NAV","true");//"true" or "none"
define("SHOW_TOP_NAV_1","true");//"true" or "none"
define("SHOW_TOP_NAV_2","true");//"true" or "none"
define("SHOW_TOP_NAV_3","true");//"true" or "none"
define("SHOW_TOP_NAV_4","true");//"true" or "none"
define("SHOW_TOP_NAV_5","true");//"true" or "none"
define("SHOW_TOP_NAV_6","true");//"true" or "none"
define("SHOW_TOP_NAV_7","true");//"true" or "none"

//充值类型 是否传递
define("PAY_TYPE",0);

//允许做支付操作的IP地址
\$ips_AllowPay = array("127.0.0.1","113.108.232.15","58.215.240.119","58.214.233.214","58.215.240.80","112.84.188.52","61.147.113.177");




//对使用smarty cache 的地方是否开启缓存
define("USE_SMARTY_CACHE",0);

//允许的服务器序号列表
\$SN_ALLOW = array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20);

/****session****/
/*
try{
    ini_set("display_errors", "0");
    ini_set("session.save_handler", "memcached");
    ini_set("session.save_path", "tcp://127.0.0.1:11211");
    ini_set("session.gc_maxlifetime",10800);
} catch (Exception \$e) {};
ini_set("display_errors", "1");
*/

session_start();

header("Content-Type: text/html; charset=utf-8");//字符集
date_default_timezone_set("Asia/Shanghai");//时区

// erl路径
define("ERL_DATA_DIR", dirname(dirname(__FILE__))."/erl_data/");
// 根路径
define("ROOT_DIR", dirname(dirname(__FILE__))."/php/");
// web路径
define("WEBROOT_DIR", dirname(dirname(__FILE__))."/html/");
// 库路径，将设置为 include path
define("LIB_DIR", ROOT_DIR . "lib/");
// 服务路径，将作为 AMF 调用发布
define("SERVICE_DIR", ROOT_DIR . "service/");
// 映射对象路径，暂时不用
define("SERVICE_VO_DIR", SERVICE_DIR . "vo/");
// 日志
define("LOG_DIR", ROOT_DIR . "log/");
// amf 日志，记录输入
define("AMF_IN_DIR", LOG_DIR . "in/");
// amf 日志，记录输出
define("AMF_OUT_DIR", LOG_DIR . "out/");
// 模块目录
define("MODULE_DIR", ROOT_DIR . "module/");
// 游戏数据缓冲目录
define("CACHE_DIR", ROOT_DIR . "cache/");
// 配置文件目录
define("CONFIG_DIR", ROOT_DIR . "config/");
//模板目录
define("TPL_DIR", ROOT_DIR."view/");

set_include_path( PATH_SEPARATOR . ROOT_DIR."module"
                . PATH_SEPARATOR . ROOT_DIR."lib"
                . PATH_SEPARATOR . ROOT_DIR."lib/Ext"
                . PATH_SEPARATOR . ROOT_DIR."service"
                . PATH_SEPARATOR . get_include_path());

include ROOT_DIR . "lib/Helper/String.php";

//通知刷新基础数据
function refresh_erlang_data(\$type)
{
    \$url = "http://". GAME_IP . ":".GAME_PORT."/load_base_data?".\$type;
    \$ch = curl_init();
    curl_setopt(\$ch, CURLOPT_URL, \$url);
    curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt(\$ch, CURLOPT_CONNECTTIMEOUT, 10);
    \$ret = curl_exec(\$ch);
    curl_close(\$ch);
    return \$ret;
}
eof

rm -rf /svn/www/php/config/db.php
cat >/svn/www/php/config/db.php <<eof
<?php

return array(
	"main" => array(
		"db" => "mongodb",		//mysql or mongodb

		"mysql_host"=>"127.0.0.1",
		"mysql_port"=>3306,
		"mysql_user"=>"root",
		"mysql_pwd"=>"root",
		"mysql_db"=>"zttx_dev",
		"mysql_charset"=>"utf8",

		"mongodb_host"=>"$dbip",
		"mongodb_port"=>"27017",
		"mongodb_user"=>null,
		"mongodb_pwd"=>null,
		"mongodb_db"=>zttx_dev
	),

	"mysql" => array(
		"db" => "mysql",

		"mysql_host"=>"127.0.0.1",
		"mysql_port"=>3306,
		"mysql_user"=>"root",
		"mysql_pwd"=>"root",
		"mysql_db"=>"zttx_dev",
		"mysql_charset"=>"utf8",
	),

	"mongo" => array(
		"db" => "mongodb",

		"mongodb_host"=>"$dbip",
		"mongodb_port"=>"27017",
		"mongodb_user"=>null,
		"mongodb_pwd"=>null,
		"mongodb_db"=>zttx_dev
    ),

     "log_mongo" => array(
        "db" => "mongodb",
		"mongodb_host"=>"$dbip",
		"mongodb_port"=>"27017",
        "mongodb_user"=>null,
        "mongodb_pwd"=>null,
        "mongodb_db"=>zttx_dev
    ),

	"mongo_slave" => array(
		"db" => "mongodb",
		"mongodb_host"=>"$dbip",
		"mongodb_port"=>"27017",
		"mongodb_user"=>null,
		"mongodb_pwd"=>null,
		"mongodb_db"=>zttx_dev
	),
);

eof
