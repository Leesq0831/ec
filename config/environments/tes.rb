require 'axlsx' 
al = Axlsx::Package.new
al.workbook do |wb|
  # define your regular styles
  styles = wb.styles
  title = styles.add_style(:sz => 15, :b => true, :u => true)
  default = styles.add_style(:border => Axlsx::STYLE_THIN_BORDER)
  header = styles.add_style(:bg_color => '00', :fg_color => 'FF', :b => true)
  money = styles.add_style(:format_code => '#,###,##0', 
                           :border => Axlsx::STYLE_THIN_BORDER)
  percent = styles.add_style(:num_fmt => Axlsx::NUM_FMT_PERCENT,   
                             :border => Axlsx::STYLE_THIN_BORDER)


  # define the style for conditional formatting - its the :dxf bit that counts!
  profitable =  styles.add_style(:fg_color=> 'FF428751',  
                                 :sz => 12, :type => :dxf, :b => true)


  wb.add_worksheet({}) do  |ws|
    ws.add_row ['A$$le Q1 Revenue Historical Analysis (USD)'], 
                :style => title
    ws.add_row
    ws.add_row ['Quarter', 'Profit', '% of Total'], :style => header
    ws.add_row ['Q1-2010', '15680000000', '=B4/SUM(B4:B7)'],  
                :style => [default, money, percent]
    ws.add_row ['Q1-2011', '26740000000', '=B5/SUM(B4:B7)'],  
                :style => [default, money, percent]
    ws.add_row ['Q1-2012', '46330000000', '=B6/SUM(B4:B7)'],  
                :style => [default, money, percent]
    ws.add_row ['Q1-2013(est)', '72000000000', '=B7/SUM(B4:B7)'],  
                :style => [default, money, percent]


    ws.merge_cells 'A1:C1'
    ws.merge_cells  'A10:A12'

    # Apply conditional formatting to range B4:B7 in the worksheet
    ws.add_conditional_formatting('B4:B7', { :type => :cellIs,
                                    :operator => :greaterThan,
                                    :formula => '27000000',
                                    :dxfId => profitable,
                                    :priority => 1 })
  end
end
al.serialize 'the_high_notes.xlsx'
