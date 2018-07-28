#!/bin/bash
#定义函数check_http：
#使用curl命令检查http服务器的状态
#-m设置curl不管访问成功或失败，最大消耗的时间为5秒，5秒连接服务为相应则视为无法连接
#-s设置静默连接，不显示连接时的连接速度、时间消耗等信息
#-o将curl下载的页面内容导出到/dev/null(默认会在屏幕显示页面内容)
#-w设置curl命令需要显示的内容%{http_code}，指定curl返回服务器的状态码
check_http(){
status_code=$(curl -m 20 -s -o /dev/null -w %{http_code} $url)
}
echo 0 > /usr/local/zhicbo/jc_count.txt
date=$(date +%Y/%m/%d-%H:%M:%S)
echo "当前时间：$date" > /usr/local/zhicbo/jc_result.log

#while read url
for url in `cat /usr/local/zhicbo/yuming.txt`
do
{
	check_http
	#指定测试服务器状态的函数，并根据返回码决定是发送邮件报警还是将正常信息写入日志
	if [ $status_code -ne 200 ] && [ $status_code -ne 301 ]  && [ $status_code -ne 200 ] && [ $status_code -ne 302 ];then
		echo 1>/usr/local/zhicbo/jc_count.txt
		echo $url域名异常,状态码为$status_code >> /usr/local/zhicbo/jc_result.log
	else
		continue
    fi       
}&
#done < /sh/yuming.txt
done
wait
echo "success"
if [ `cat /usr/local/zhicbo/jc_count.txt` ];then
	:
	#echo $count > /sh/jc_count.txt
	#echo "放心，我还在，列表域名正常" | mail -s "域名监测结果：" cleartly.org@etlgr.com
else
	#echo $count > /sh/jc_count.txt
	mail -s "域名监测警报：" bs1159780413@qq.com  < /usr/local/zhicbo/jc_result.log
fi
