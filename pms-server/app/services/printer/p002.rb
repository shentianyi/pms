# Print BAI KANBAN
module Printer
  class P002<Base
    HEAD=[:kanban_nr,:part_nr,:wire_nr,:customer_nr,:card_quantity,:safe_quantity,:card_number,:work_time,:send_position,
    :wire_description,:wire_length,:bundle_number,:strip_length1,:terminal_custom_nr1,:terminal_nr1,:seal_custom_nr1,:seal_nr1,
                                                        :strip_length2,:terminal_custom_nr2,:terminal_nr2,:seal_custom_nr2,:seal_nr2,
          :apab_description,:remark,:kanban_2dcode]

    def generate_data
      @kanban = Kanban.find_by_id(self.id)
      #Now the Automatic KANBAN onlu has 1 process entity
      @process_entity = @kanban.process_entities.first
      #应该是固定的，消耗的原材料，填入
      head={
          kanban_nr:@kanban.nr,
          part_nr:@kanban.product_nr,
          wire_nr:@kanban.part_nr,
          customer_nr: @kanban.product_custom_nr,
          card_quantity:@kanban.quantity,
          safe_quantity:@kanban.safety_stock,
          card_number:@kanban.copies,
          work_time:@kanban.task_time,
          send_position:@kanban.source_position,
          wire_description:@kanban.part_custom_nr,
          kanban_2dcode: @kanban.printed_2DCode,
          wire_length:100,
          bundle_number:@kanban.bundle,
          strip_length1:3.5,
          terminal_custom_nr1:'ct001',
          terminal_nr1:'t001',
          seal_custom_nr1:'cs001',
          seal_nr1:'s001',
          strip_length2:4,
          terminal_custom_nr2:'ct002',
          terminal_nr2:'t002',
          seal_custom_nr2:'cs002',
          seal_nr2:'s002',
          apab_description:'i really donnot known',
          remark:'time...time...time'
      }
      heads=[]
      HEAD.each do |k|
        heads<<{Key:k,Value:head[k]}
      end

      self.data_set<<heads

    end
  end
end