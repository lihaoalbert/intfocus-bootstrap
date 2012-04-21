class CategoriesController < EntitiesController
  def index
    @categoryid = params[:id]
    @userid = @current_user.id
    if @categoryid == nil || @categoryid == "" then
      @categories = Category.find(:all, :conditions => "parent_id is null " )
      @categoriesun = Category.find(:all, :conditions => "parent_id = #{@categories[0].id} " )
      @categorypath = flist(@categories[0].id, "")
      @categoryid = @categories[0].id
    else
      @categories = Category.find(:all, :conditions => "parent_id is null " )
      @categoriesun = Category.find(:all, :conditions => "parent_id = #{@categoryid} " )
      @categorypath = flist(params[:id], "")
    end

  end
  
  def createcategory
    @category = Category.create({
                :name => params[:dn], 
                :user_id => @current_user, 
                :parent_id => params[:id]
              })

    redirect_to :action=>"index/#{params[:id]}"
  end
  
  def flist(id, str)
 
    fid = Category.find(id)
 
    str = "<a href='/categories/index?id=#{fid.id}'>" + fid.name.to_s + "</a>"
    if fid.parent_id != nil then
      str = "<a href='/categories/index?id=#{fid.id}'>" + flist(fid.parent_id,str) + "</a>" + "\\" + str
    end
    return str
  end
  
  def updatecategory
    @did = params[:doc_id]
    @dcid = params[:drpdcid]
    @isdc_type = params[:isdc_type] 
    @chkeas_type = params[:chkeas_type]
    @chkeke_type = params[:chkeke_type]
    @chkac_type = params[:chkac_type]
    @chkeac_type = params[:chkeac_type]
    @fpdata = params[:fpdata]
    @dpdata = params[:dpdata]
    Category.update(@did,{
      :is_single_document_class => @isdc_type,
      :document_class_id => @dcid,
      :allow_categorize => @chkac_type,
      :allow_discussing => @chkeac_type,
      :auto_keywords => @chkeke_type,
      :auto_description => @chkeas_type,
    })
  end
  
  def editcategory
    @lstas = ""
    @fp = ""
    @dp = ""
    @categoryid = params[:id]
    @userid = @current_user.id
    #@docclass = DocumentClass.find(:all, :conditions => "user_id = '#{@userid}'")
    @category = Category.find(@categoryid)
    fpv = FldPrivilege.find_by_resource_id(@categoryid);
    ddp = DefaultDocPrivilege.find_by_resource_id(@categoryid)
    fpv.data.to_s.split("^").each do |f|
      @lstas = @lstas + "<option value='#{f.split("|")[1]}'>#{f.split("|")[0]}</option>"
      @fp = @fp + foption(f.split("|")[2],f.split("|")[1])
    end
    
    ddp.data.split("^").each do |f|
      @dp = @dp + doption(f.split("|")[2],f.split("|")[1])
    end
  end
  
  def usercategory
    @users = User.all
  end
  
  def foption(num,pid)
    fop = ""
    case num.to_i
    when 1
      fop = "<option value='1' parent_id='#{pid}'>1</option>"
    when 2
      fop = "<option value='2' parent_id='#{pid}'>2</option>"
    when 3
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option>"
    when 4
      fop = "<option value='4' parent_id='#{pid}'>4</option>"
    when 5
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option>"
    when 6
      fop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 7
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 8
      fop = "<option value='8' parent_id='#{pid}'>8</option>"
    when 9
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='8' parent_id='#{pid}'>8</option>"
    when 10
      fop = "<option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 11
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 12
      fop = "<option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 13
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 14
      fop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"      
    when 15
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    end
    return fop
  end
  
  def doption(num,pid)
    dop = ""
    case num.to_i
    when 1
      dop = "<option value='1' parent_id='#{pid}'>1</option>"
    when 2
      dop = "<option value='2' parent_id='#{pid}'>2</option>"
    when 3
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option>"
    when 4
      dop = "<option value='4' parent_id='#{pid}'>4</option>"
    when 5
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option>"
    when 6
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 7
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 8
      dop = "<option value='8' parent_id='#{pid}'>8</option>"
    when 9
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='8' parent_id='#{pid}'>8</option>"
    when 10
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 11
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 12
      dop = "<option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 13
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 14
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"      
    when 15
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 16
      dop = "<option value='16' parent_id='#{pid}'>16</option>"
    when 17
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='16' parent_id='#{pid}'>16</option>"
    when 18
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 19
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 20
      dop = "<option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 21
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 22
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 23
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 24
      dop = "<option value='8' parent_id='#{pid}'>8</option><option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 25
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='8' parent_id='#{pid}'>8</option><option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 26
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 27
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    when 28
      dop = "<option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    when 29
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"      
    when 30
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    when 31
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    end
      
    return dop
  end
end
