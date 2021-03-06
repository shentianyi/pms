module PartBomable
  extend ActiveSupport::Concern

  included do
    after_create :create_part_bom
    # after_update :update_part_bom
    after_save :update_part_bom
    after_destroy :update_part_bom
  end

  def update_part_bom
    if self.is_a?(KanbanProcessEntity)
      self.kanban.create_part_bom if self.kanban
    elsif self.is_a?(CustomValue)
      if self.customized.is_a?(ProcessEntity)
        self.customized.kanbans.each do |kanban|
          kanban.create_part_bom
        end
      end
    elsif self.is_a?(ProcessPart)
      self.process_entity.kanbans.each do |kanban|
        puts "$$$$$$$ ProcessPart : #{self.to_json}".yellow
        kanban.create_part_bom
      end
      # elsif self.is_a?(ProcessEntity)
      # self.kanbans.each do |kanban|
      #   kanban.create_part_bom
      # end
    elsif self.is_a?(Kanban)
      #self.create_part_bom #if self.state==KanbanState::DESTROYED
    end
  end


  def create_part_bom(force=true)
    if self.is_a?(Kanban)
      if force || self.kanban_part.nil?

        PartBom.transaction do
          if self.process_entities.count>0
            # create part for kanban
            if !self.kanban_part
              # if self.ktype==KanbanType::BLUE
              if self.kanban_part_nr
                self.kanban_part=Part.create(nr: self.kanban_part_nr, type: PartType::PRODUCT_SEMIFINISHED, remark: '创建BOM时系统自动生成')
                puts "-----create kanban part nr#{self.kanban_part.to_json}---------".blue
              end
              # end
            end

            puts "##----start bom:#{self.kanban_part.to_json}:#{self.kanban_part_nr}".yellow
            part=self.kanban_part
            arrs=part.part_boms.pluck(:id)

            part.part_boms.update_all(quantity: 0)
            self.process_parts.reload.each do |process_part|
              puts "#{process_part.to_json}".red
              if part_bom_item=Part.find_by_id(process_part.part_id)
                qty=process_part.quantity||0
                # raise '用量超过100' if qty>=100
                if item=part.part_boms.find_by_bom_item_id(part_bom_item.id)
                  if part_bom_item.type==PartType::PRODUCT_SEMIFINISHED
                    puts "update semi part ----#{part_bom_item.nr}".blue
                    item.update_attributes(quantity: qty) if item.quantity==0
                  elsif PartType.is_material?(part_bom_item.type)
                    puts "update material ----#{part_bom_item.nr}".yellow
                    item.update_attributes(quantity: item.quantity+qty)
                  end
                  arrs.delete(item.id)
                else
                  part.part_boms<<PartBom.new(bom_item_id: part_bom_item.id, quantity: qty)
                end
              else
                raise "kb_id:#{self.to_json},process_entity_id:#{process_part.to_json}#no part id #{process_part.part_id}".red unless process_part.part_id.blank?
              end
            end

            puts "#{Part.where(id: arrs).pluck(:nr).join(' , ')},#{arrs.size}".red
            part.part_boms.where(id: arrs).destroy_all
          end
        end
      end
    end
  end

  def kanban_part_nr
    if self.is_a?(Kanban)
      @kanban_part_nr||= (self.full_wire_nr || (self.process_entities.first.nil? ? nil : "#{Part.find_by_id(self.product_id).nr}_#{self.process_entities.first.nr}"))
    else
      @kanban_part_nr||=nil
    end
  end

  def kanban_part
    if self.is_a?(Kanban)
      @kanban_part||= Part.find_by_nr(@kanban_part_nr||kanban_part_nr)
    else
      @kanban_part||=nil
    end
  end

  def kanban_part= v
    @kanban_part=v
  end


  def materials
    if self.kanban_part
      self.kanban_part.materials
    else
      []
    end
  end

  # def materials_with_deep
  #   if self.kanban_part
  #     self.kanban_part.materials
  #   else
  #     []
  #   end
  # end
end
