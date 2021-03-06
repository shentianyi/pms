class PartsController < ApplicationController
  before_action :set_part, only: [:show, :edit, :update, :destroy,
                                  :add_process_entities, :delete_process_entities]

  # GET /parts
  # GET /parts.json
  def index
    @parts = Part.paginate(:page => params[:page])
    #@q = Part.ransack(params[:q])
    #@parts = @q.result.paginate(:page => params[:page])
    respond_to do |format|
      format.html
      format.csv { send_data @parts.to_csv }
    end
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
    #authorize @part
  end

  # GET /parts/new
  def new
    @part = Part.new
    #authorize @part
  end

  # GET /parts/1/edit
  def edit
    #authorize @part
  end

  # POST /parts
  # POST /parts.json
  def create
    msg = Message.new
    @part = Part.new(part_params)
    # authorize(@part)

    respond_to do |format|
      if @part.save
        msg.result = true
        msg.content = @part
        format.html { redirect_to @part, notice: 'Part was successfully created.' }
        format.json { render json: msg }
      else
        msg.result = false
        msg.content = @part.errors
        format.html { render :new }
        format.json { render json: msg, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parts/1
  # PATCH/PUT /parts/1.json
  def update
    # authorize @part
    respond_to do |format|
      if @part.update(part_params)
        format.html { redirect_to @part, notice: 'Part was successfully updated.' }
        format.json { render :show, status: :ok, location: @part }
      else
        format.html { render :edit }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.json
  def destroy
    @part.destroy
    respond_to do |format|
      format.html { redirect_to parts_url, notice: 'Part was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /parts/search
  # GET /parts/search.json
=begin
  def search
  end
=end

  # POST /parts/1/add_process_entitties
=begin
  def add_process_entities
    if (@part.kanbans.select { |k| k.can_update? == false }).count>0
      render json: {result: false, content: "不能修改Routing，因为有关联该Part的KANBAN正在生产!"} and return
    end

    params[:process_entities].each { |pe_id|
      @part.part_process_entities<<PartProcessEntity.create(process_entity_id: pe_id)
    }

    if @part.save
      render json: {result: true, content: {}}
    else
      render json: {result: false, content: {}}
    end
  end
=end

  # DELETE /parts/1/delete_process_entities
=begin
  def delete_process_entities
    msg = Message.new
    msg.result = true

    if (@part.kanbans.select { |k| k.can_update? == false }).count>0
      msg.result = false
      msg.content = "不能修改Routing，因为有关联该Part的KANBAN正在生产!"
      render json: msg and return
    end
    ActiveRecord::Base.transaction do
      begin
        @part.part_process_entities.where(process_entity_id: params[:process_entities]).each { |x| x.destroy }
      rescue
        msg.result = false
      end
    end

    render json: msg
  end
=end

  def import
    # authorize(Part)
    if request.post?
      msg = Message.new
      begin
        file=params[:files][0]
        fd = FileData.new(data: file, original_name: file.original_filename, path: $upload_data_file_path, path_name: "#{Time.now.strftime('%Y%m%d%H%M%S%L')}~#{file.original_filename}")
        fd.save
        file=FileHandler::Csv::File.new(user_agent: request.user_agent.downcase, file_path: fd.full_path, file_name: file.original_filename)
        msg = FileHandler::Csv::PartHandler.import(file)
      rescue => e
        msg.content = e.message
      end
      render json: msg
    end
  end


  def import_update
    if request.post?
      msg = Message.new
      begin
        file=params[:files][0]
        fd = FileData.new(data: file, original_name: file.original_filename, path: $upload_data_file_path, path_name: "#{Time.now.strftime('%Y%m%d%H%M%S%L')}~#{file.original_filename}")
        fd.save
        file=FileHandler::Csv::File.new(user_agent: request.user_agent.downcase, file_path: fd.full_path, file_name: file.original_filename)
        msg = FileHandler::Csv::PartHandler.update(file)
      rescue => e
        msg.content = e.message
      end
      render json: msg
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part
      @part = Part.find(params[:id])
      # authorize(@part)
    end

  # Never trust parameters from the scary internet, only allow the white list through.
  def part_params
    params.require(:part).permit(:nr, :custom_nr, :type, :cross_section,:strip_length,:component_type,
                                 :resource_group_id, :measure_unit_id, :description,:color,:color_desc,:unit,:desc1,:pno,:nick_name)
  end
end
