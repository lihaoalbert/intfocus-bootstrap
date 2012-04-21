#encoding:utf-8
require 'rss/1.0'         
require 'rss/2.0'         
require 'open-uri'
class ReaderController < ApplicationController
  def index
    feed = "http://news.google.com.hk/news?hl=zh-CN&gl=cn&q=&um=1&ie=UTF-8&output=rss"
    @strkeyword = params[:txtkeyword]
    g = params[:google].to_s
    b = params[:baidu].to_s
    gitem = Array.new
    bitem = Array.new
    #if strkeyword == "" || strkeyword == nil then
    #  cookies[:txtkeyword] = nil
    #  strkeyword = ""
    #else
    #  cookies[:txtkeyword] = strkeyword
    #end
    if g != "" && g != nil then
      @google = true
      feed= "http://news.google.com.hk/news?hl=zh-CN&gl=cn&q=#{params[:txtkeyword]}&um=1&ie=UTF-8&output=rss" # url或本地XML文件
      gitem = readrss(feed)
    end
    
    if b != "" && b != nil then
      @baidu = true
      feed = "http://news.baidu.com/ns?word=#{params[:txtkeyword]}==""? '':#{params[:txtkeyword]}&ie=UTF-8&tn=newsrss&sr=0&cl=20&rn=10&ct=0"
      bitem = readrss(feed)
    end
    #feed = "http://rubyforge.org/export/rss_sfnewreleases.php" 
         
    @items = bitem + gitem
  end

  
  def readrss(strfeed)
    content = ""         
    open(URI.escape(strfeed)) do |s|       
      content = s.read
    end
    rss = RSS::Parser.parse(content, false) # false表示不验证feed的合法性  
    return rss.channel.items # rss.channel.items亦可 
  end
end