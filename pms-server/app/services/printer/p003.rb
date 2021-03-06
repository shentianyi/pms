# Print BUNDLE LABEL
module Printer
  class P003<Base
    HEAD=[:CO_Nr, :CP_Nr,
          :kBanNr,:user, :warehouse,
          :pnNr, :bundleNo, :totalQuantity, :bQuantity, :singleResCC, :wireNr,
          :partNr, :partDesc, :color, :length, :diameter,
          :t1_nr, :t1_custom_nr, :t1_strip_length, :s1_nr,
          :t2_nr, :t2_custom_nr, :t2_strip_length, :s2_nr,
          :bundleLabelNr]

    def generate_data(args=nil)
      item=ProductionOrderItem.find_by_nr(args[:order_item_nr])
      kanban = Kanban.find_by_id(self.id)
      if item_label=item.production_order_item_labels.where(bundle_no: args[:bundle_no]).first

        product=Part.find_by_id(kanban.product_id)

      #  raise '' if product
        #Now the Automatic KANBAN onlu has 1 process entity
        process_entity = kanban.process_entities.first
        wire=Part.find_by_id(process_entity.value_wire_nr)

        head={
            CO_Nr: item.nr,
            CP_Nr: item.optimise_index,
            user: item.user_nr.blank? ? '' : "#{item.user_nr} / #{item.user_group_nr}",
            kBanNr: kanban.nr,
            warehouse: kanban.des_storage,
            pnNr: (product.nil? ? '' : "#{product.nr} / #{product.custom_nr}"),
            bundleNo: args[:bundle_no],
            totalQuantity: kanban.quantity,
            bQuantity: item_label.qty.to_i,
            singleResCC: args[:machine_nr],
            wireNr: kanban.wire_nr,
            partNr: wire.nr,
            partDesc: "#{wire.component_type}  #{wire.description}",
            color: wire.color,
            length: process_entity.value_wire_qty_factor,
            diameter: wire.cross_section,
            t1_nr: '', t1_custom_nr: '', t1_strip_length: '', s1_nr: '',
            t2_nr: '', t2_custom_nr: '', t2_strip_length: '', s2_nr: '',
            bundleLabelNr: item_label.nr
        }

        %w(t1 t2 s1 s2).each { |cf|
          value = process_entity.send("value_#{cf}")
          if value && part = Part.find_by_id(value)
            head["#{cf}_custom_nr".to_sym] = part.custom_nr if head.has_key?("#{cf}_custom_nr".to_sym)
            head["#{cf}_nr".to_sym] = part.nr if head.has_key?("#{cf}_nr".to_sym)
          end
          head["#{cf}_strip_length".to_sym]=process_entity.send("#{cf}_strip_length") if head.has_key?("#{cf}_strip_length".to_sym)
        }

        heads=[]
        HEAD.each do |k|
          heads<<{Key: k, Value: head[k]}
        end

        self.data_set<<heads
      end
    end
  end
end
