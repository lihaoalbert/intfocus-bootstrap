# Intfocus Project Init
# Copyright (C) 2011-2012 by Intfocus Corp.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class MacroeconomicsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /macroeconomics
  #----------------------------------------------------------------------------
  def index
    @macroeconomics = get_macroeconomics(:page => params[:page])
    respond_with(@macroeconomics)
  end

  # GET /macroeconomics/1
  #----------------------------------------------------------------------------
  def show
    @macroeconomic = Macroeconomic.my.find(params[:id])

    respond_with(@macroeconomic) do |format|
      format.html do
        #@stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@macroeconomic)
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :json, :xml)
  end

  # GET /macroeconomics/new
  # GET /macroeconomics/new.json
  # GET /macroeconomics/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def new
    @macroeconomic = Macroeconomic.new(:user => @current_user, :access => Setting.default_access)
    @users = User.except(@current_user)
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@macroeconomic)
  end

  # GET /macroeconomics/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  def edit
    @macroeconomic = Macroeconomic.my.find(params[:id])
    @users = User.except(@current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Macroeconomic.my.find($1)
    end
    respond_with(@macroeconomic)

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @macroeconomic
  end

  # POST /macroeconomics
  #----------------------------------------------------------------------------
  def create
    @macroeconomic = Macroeconomic.new(params[:macroeconomic])
    @users = User.except(@current_user)
    
    respond_with(@macroeconomic) do |format|
      if @macroeconomic.save_with_permissions(params[:users])
        @macroeconomics = get_macroeconomics
        get_data_for_sidebar
      end
    end
  end

  # PUT /macroeconomics/1
  #----------------------------------------------------------------------------
  def update
    @macroeconomic = Macroeconomic.my.find(params[:id])

    respond_with(@macroeconomic) do |format|
      if @macroeconomic.update_with_permissions(params[:macroeconomic], params[:users])
        get_data_for_sidebar if called_from_index_page?
      else
        @users = User.except(@current_user) # Need it to redraw [Edit Macroeconomic] form.
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :json, :xml)
  end

  # DELETE /macroeconomics/1
  #----------------------------------------------------------------------------
  def destroy
    @macroeconomic = Macroeconomic.my.find(params[:id])
    @macroeconomic.destroy if @macroeconomic

    respond_with(@macroeconomic) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :json, :xml)
  end

  # PUT /macroeconomics/1/attach
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :attach

  # PUT /macroeconomics/1/discard
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :discard

  # POST /macroeconomics/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /macroeconomics/options                                                 AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:macroeconomics_per_page] || Macroeconomic.per_page
      @outline  = @current_user.pref[:macroeconomics_outline]  || Macroeconomic.outline
      @sort_by  = @current_user.pref[:macroeconomics_sort_by]  || Macroeconomic.sort_by
    end
  end

  # GET /accounts/leads                                                    AJAX
  #----------------------------------------------------------------------------
  def leads
    @macroeconomic = Macroeconomic.my.find(params[:id])
  end

  # GET /accounts/opportunities                                            AJAX
  #----------------------------------------------------------------------------
  def opportunities
    @macroeconomic = Macroeconomic.my.find(params[:id])
  end

  # POST /macroeconomics/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:macroeconomics_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:macroeconomics_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:macroeconomics_sort_by]  = Macroeconomic::sort_by_map[params[:sort_by]] if params[:sort_by]
    @macroeconomics = get_macroeconomics(:page => 1)
    render :index
  end

  # POST /macroeconomics/filter                                                 AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:filter_by_macroeconomic_country] = params[:country]
    @macroeconomics = get_macroeconomics(:page => 1)
    render :index
  end

# import test
  def imexport
    @fulltext = params[:fulltext]
    @search = Account.search do
      fulltext params[:fulltext].to_s
       # fields(:title)
       #with :testid, [1,111]
      #end
      #with(:created_at).between((params[:start_date]== "" ? '1970-01-01':params[:start_date])..(params[:end_date]== "" ? Time.now.strftime('%Y-%m-%d') : params[:end_date]))
      #fulltext '中' do
        #with :id, 3
      #end

      #with :title, '的'
      order_by(:created_at, :desc)
    end

  end

# import test
  def export
    @macroeconomics = Macroeconomic.my.all
    respond_to do |format|
      format.xls {
        send_data(xls_content_for(@macroeconomics),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "Report_Macroeconomics_#{Time.now.strftime("%Y%m%d%H%M")}.xls")
      }
    end
  end

  def import
    excel_file = params[:excel_file]
    file = ImportUploader.new
    file.store!(excel_file)
    book = Spreadsheet.open "#{file.store_path}"
    sheet1 = book.worksheet 0
    @macroeconomics = []
    @errors = Hash.new
    @counter = 0

    sheet1.each 1 do |row|
      @counter+=1
      p = Macroeconomic.new
      Macroeconomic.get_field_array.each_with_index do |field, i|
        p.send("#{field[0]}=", row[i])
      end

      if p.valid?
        p.save!
        @macroeconomics << p
      else
        @errors["#{@counter+1}"] = p.errors
      end
    end
    file.remove!
  end

  def import_template
    respond_to do |format|
      format.xls {
        send_data(xls_content_for(nil),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "Template_Macroeconomics_#{Time.now.strftime("%Y%m%d%H%M")}.xls")
      }
    end
  end

  private
  def xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Macroeconomics"

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat Macroeconomic.get_field_array.collect{|arr| arr[1] }
    count_row = 1
    if objs
      objs.each do |obj|
        columns = Macroeconomic.get_field_array.collect{|arr| arr[0] }
        columns.each_with_index do |column_name, i|
          sheet1[count_row, i] = obj.send(column_name)
        end
        count_row += 1
      end
    end

    book.write xls_report
    xls_report.string
  end
# import test
  #private
  #----------------------------------------------------------------------------
  def get_macroeconomics(options = {})
    get_list_of_records(Macroeconomic, options.merge!(:filter => :filter_by_macroeconomic_country))
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @macroeconomics = get_macroeconomics
      if @macroeconomics.blank?
        @macroeconomics = get_macroeconomics(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render destroy.js.rjs
    else # :html request
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @macroeconomic.country + ' - ' + @macroeconomic.year)
      redirect_to macroeconomics_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @macroeconomic_country_total = { :all => Macroeconomic.my.count, :other => 0 }
    Setting.macroeconomic_country.each do |key|
      @macroeconomic_country_total[key] = Macroeconomic.my.where(:country => key.to_s).count
      @macroeconomic_country_total[:other] -= @macroeconomic_country_total[key]
    end
    @macroeconomic_country_total[:other] += @macroeconomic_country_total[:all]
  end
end
