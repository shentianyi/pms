class ProductionOrderItemPresenter<Presenter
  Delegators=[:id, :nr, :production_order, :production_order_id, :machine_id, :machine]
  def_delegators :@production_order_item, *Delegators

  def initialize(production_order_item)
    @production_order_item=production_order_item
    self.origin=production_order_item
    self.delegators=Delegators
  end

  def to_bundle_produce_order
    kanban=@production_order_item.kanban
    {
        Id: @production_order_item.id,
        ItemNr: @production_order_item.nr,
        TotalQuantity: @production_order_item.kanban_qty,
        BundleQuantity: @production_order_item.kanban_bundle,
        ProducedQty: @production_order_item.produced_qty
    }
  end

  def self.init_preview_presenters(params)
    params.map.with_index { |param, i| self.new(param).to_preview_order(i+1) }.reject { |p| p.blank? }
  end

  def to_preview_order(no=0)
    to_check_material_order(no)
  end

  def to_check_material_order(no=0)
    kanban=@production_order_item.kanban
    puts @production_order_item.id
    # puts kanban.nr
    # puts kanbanz.red
    if kanban && (process_entity=kanban.process_entities.first)

      product=Part.find_by_id(kanban.product_id)
      machine=Machine.find_by_id(@production_order_item.machine_id)

      wire=Part.find_by_id(process_entity.value_wire_nr)
      puts "#{self.to_json}------#{kanban.to_json}==============#{process_entity.value_wire_nr}".red
      t1=Part.find_by_id(process_entity.value_t1)
      tool1=t1.nil? ? nil : t1.tool_nrs

      t2=Part.find_by_id(process_entity.value_t2)
      tool2=t2.nil? ? nil : t2.tool_nrs

      s1=Part.find_by_id(process_entity.value_s1)
      s2=Part.find_by_id(process_entity.value_s2)
      if Setting.presenter_change_item_qty? && @production_order_item.can_change_kanban_qty?
        @production_order_item.update_attributes(kanban_bundle:kanban.bundle,kanban_qty:kanban.quantity)
      end

      item= {
          No: no,
          Id: @production_order_item.id,
          ItemNr: @production_order_item.nr,
          State: @production_order_item.state,
          IsUrgent: @production_order_item.is_urgent,
          OptimiseIndex: @production_order_item.optimise_index,
          OrderNr: @production_order_item.production_order.nil? ? '' : @production_order_item.production_order.nr,
          Machine: machine.nil? ? '' : machine.nr,
          FileName: "#{@production_order_item.nr}.json",
          ProductNr: product.nil? ? '' : product.nr,
          KanbanNr: kanban.nr,
          KanbanQuantity: @production_order_item.kanban_qty,
          KanbanBundle: @production_order_item.kanban_bundle,
          ProducedQty: @production_order_item.produced_qty,
          KanbanWireNr: kanban.wire_nr,
          WireNr:wire.nil? ? '' : wire.nr,
          Diameter:wire.nil? ? '' :  wire.cross_section,
          WireCusNr:wire.nil? ? '' :  wire.custom_nr||'',
          WireColor:wire.nil? ? '' :  wire.color,
          WireLength: process_entity.value_wire_qty_factor.to_f,
          Terminal1Nr: t1.nil? ? nil : t1.nr,
          Terminal1CusNr: t1.nil? ? nil : t1.custom_nr,
          Terminal1StripLength: process_entity.t1_strip_length.nil? ? nil : process_entity.t1_strip_length.to_f,
          Tool1Nr: tool1,
          Terminal2Nr: t2.nil? ? nil : t2.nr,
          Terminal2CusNr: t2.nil? ? nil : t2.custom_nr,
          Terminal2StripLength: process_entity.t2_strip_length.nil? ? nil : process_entity.t2_strip_length.to_f,
          Tool2Nr: tool2,
          Seal1Nr: s1.nil? ? nil : s1.nr,
          Seal2Nr: s2.nil? ? nil : s1.nr,
          UpdateTime: @production_order_item.updated_at.localtime
      }
      # @production_order_item.update_attributes(tool1: item[:Terminal1Nr], tool2: item[:Terminal2Nr])
      return item
    end

    # {
    #     No: 0,
    #     Id: 102,
    #     ItemNr: "000102",
    #     OrderNr: "000001",
    #     FileName: "000102.json",
    #     WireNr: "76755022W116",
    #     WireCusNr: "FLRYW-B 0",
    #     WireLength: 2060,
    #     Terminal1Nr: 'nil',
    #     Terminal1CusNr: 'nil',
    #     Terminal1StripLength: 1,
    #     Tool1Nr: 'nil',
    #     Terminal2Nr: 'nil',
    #     Terminal2CusNr: 'nil',
    #     Terminal2StripLength: 1,
    #     Tool2Nr: 'nil',
    #     Seal1Nr: 'nil',
    #     Seal2Nr: nil
    # }
  end

  def to_produce_order(machine_type=nil,mirror=false)
    Ncr::Order.new.json_order_item_content(@production_order_item, machine_type,mirror)
  end
end