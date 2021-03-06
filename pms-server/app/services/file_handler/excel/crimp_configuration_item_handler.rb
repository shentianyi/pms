module FileHandler
  module Excel
    class CrimpConfigurationItemHandler<Base
      HEADERS=[
          'Part No.', 'Component P/N', 'Material Qty Per Harness', 'Dep', 'Delete'
      ]

      def self.import(file, crimp_configuration_id)
        puts '-----------------------------------------------------------------'
        puts crimp_configuration_id
        msg = Message.new
        book = Roo::Excelx.new file.full_path
        book.default_sheet = book.sheets.first

        validate_msg = validate_import(file)
        if true#validate_msg.result
          #validate file
          begin
            CrimpConfigurationItem.transaction do

              # 2.upto(book.last_row) do |line|
              #   row = {}
              #   HEADERS.each_with_index do |k, i|
              #     row[k] = book.cell(line, i+1).to_s.strip
              #     row[k]=row[k].sub(/\.0/, '') if k=='Part No.' || k=='Component P/N'
              #   end
              #
              #   product=Part.find_by_nr(row['Part No.'])
              #   bom_item= Part.find_by_nr(row['Component P/N'])
              #   department= Department.find_by_code(row['Dep'])
              #
              #   if item=MasterBomItem.where(product_id: product.id, bom_item_id: bom_item.id, department_id: department.id).first
              #     if row['Delete'].to_i==1
              #       item.destroy
              #     end
              #   else
              #     CrimpConfigurationItem.create(product_id: product.id,
              #                          bom_item_id: bom_item.id,
              #                          qty: row['Material Qty Per Harness'],
              #                          department_id: department.id)
              #   end
              #
              # end
            end
            msg.result = true
            msg.content = "ISO标准值 上传成功"
          rescue => e
            puts e.backtrace
            msg.result = false
            msg.content = e.message
          end
        else
          msg.result = false
          msg.content = validate_msg.content
        end
        msg
      end




      def self.validate_import file
        tmp_file=full_tmp_path(file.original_name)
        msg = Message.new(result: true)
        book = Roo::Excelx.new file.full_path
        book.default_sheet = book.sheets.first

        p = Axlsx::Package.new
        p.workbook.add_worksheet(:name => "Basic Worksheet") do |sheet|
          sheet.add_row HEADERS+['Error Msg']
          #validate file
          2.upto(book.last_row) do |line|
            row = {}
            HEADERS.each_with_index do |k, i|
              row[k] = book.cell(line, i+1).to_s.strip
            end

            mssg = validate_row(row, line)
            if mssg.result
              sheet.add_row row.values
            else
              if msg.result
                msg.result = false
                msg.content = "下载错误文件<a href='/files/#{Base64.urlsafe_encode64(tmp_file)}'>#{::File.basename(tmp_file)}</a>"
              end
              sheet.add_row row.values<<mssg.content
            end
          end
        end
        p.use_shared_strings = true
        p.serialize(tmp_file)
        msg
      end

      def self.validate_row(row, line)
        msg=Message.new(contents: [])

        unless msg.result=(msg.contents.size==0)
          msg.content=msg.contents.join('/')
        end
        return msg
      end

    end
  end
end