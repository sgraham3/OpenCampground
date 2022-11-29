class Setup::ColorController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Colors
#####################################################
  def index
    @page_title = 'Colors'
    @colors = Color.all :order => "name asc"
  end

  def edit
    @page_title = 'Edit a color'
    @color = Color.find(params[:id])
    @colors = %w( Black Navy DarkBlue MediumBlue Blue DarkGreen Green Teal DarkCyan DeepSkyBlue DarkTurquoise MediumSpringGreen Lime SpringGreen Aqua Cyan MidnightBlue DodgerBlue LightSeaGreen ForestGreen SeaGreen DarkSlateGray DarkSlateGrey LimeGreen MediumSeaGreen Turquoise RoyalBlue SteelBlue DarkSlateBlue MediumTurquoise Indigo  DarkOliveGreen CadetBlue CornflowerBlue MediumAquaMarine DimGray DimGrey SlateBlue OliveDrab SlateGray SlateGrey LightSlateGray LightSlateGrey MediumSlateBlue LawnGreen Chartreuse Aquamarine Maroon Purple Olive Gray Grey SkyBlue LightSkyBlue BlueViolet DarkRed DarkMagenta SaddleBrown DarkSeaGreen LightGreen MediumPurple DarkViolet PaleGreen DarkOrchid YellowGreen Sienna Brown DarkGray DarkGrey LightBlue GreenYellow PaleTurquoise LightSteelBlue PowderBlue FireBrick DarkGoldenRod MediumOrchid RosyBrown DarkKhaki Silver MediumVioletRed IndianRed Peru Chocolate Tan LightGray LightGrey PaleVioletRed Thistle Orchid GoldenRod Crimson Gainsboro Plum BurlyWood LightCyan Lavender DarkSalmon Violet PaleGoldenRod LightCoral Khaki AliceBlue HoneyDew Azure SandyBrown Wheat Beige WhiteSmoke MintCream GhostWhite Salmon AntiqueWhite Linen LightGoldenRodYellow OldLace Red Fuchsia Magenta DeepPink OrangeRed Tomato HotPink Coral Darkorange LightSalmon Orange LightPink Pink Gold PeachPuff NavajoWhite Moccasin Bisque MistyRose BlanchedAlmond PapayaWhip LavenderBlush SeaShell Cornsilk LemonChiffon FloralWhite Snow Yellow LightYellow Ivory White )
    @hex = %w( #000000 #000080 #00008B #0000CD #0000FF #006400 #008000 #008080 #008B8B #00BFFF #00CED1 #00FA9A #00FF00 #00FF7F #00FFFF #00FFFF #191970 #1E90FF #20B2AA #228B22 #2E8B57 #2F4F4F #2F4F4F #32CD32 #3CB371 #40E0D0 #4169E1 #4682B4 #483D8B #48D1CC #4B0082 #556B2F #5F9EA0 #6495ED #66CDAA #696969 #696969 #6A5ACD #6B8E23 #708090 #708090 #778899 #778899 #7B68EE #7CFC00 #7FFF00 #7FFFD4 #800000 #800080 #808000 #808080 #808080 #87CEEB #87CEFA #8A2BE2 #8B0000 #8B008B #8B4513 #8FBC8F #90EE90 #9370D8 #9400D3 #98FB98 #9932CC #9ACD32 #A0522D #A52A2A #A9A9A9 #A9A9A9 #ADD8E6 #ADFF2F #AFEEEE #B0C4DE #B0E0E6 #B22222 #B8860B #BA55D3 #BC8F8F #BDB76B #C0C0C0 #C71585 #CD5C5C #CD853F #D2691E #D2B48C #D3D3D3 #D3D3D3 #D87093 #D8BFD8 #DA70D6 #DAA520 #DC143C #DCDCDC #DDA0DD #DEB887 #E0FFFF #E6E6FA #E9967A #EE82EE #EEE8AA #F08080 #F0E68C #F0F8FF #F0FFF0 #F0FFFF #F4A460 #F5DEB3 #F5F5DC #F5F5F5 #F5FFFA #F8F8FF #FA8072 #FAEBD7 #FAF0E6 #FAFAD2 #FDF5E6 #FF0000 #FF00FF #FF00FF #FF1493 #FF4500 #FF6347 #FF69B4 #FF7F50 #FF8C00 #FFA07A #FFA500 #FFB6C1 #FFC0CB #FFD700 #FFDAB9 #FFDEAD #FFE4B5 #FFE4C4 #FFE4E1 #FFEBCD #FFEFD5 #FFF0F5 #FFF5EE #FFF8DC #FFFACD #FFFAF0 #FFFAFA #FFFF00 #FFFFE0 #FFFFF0 #FFFFFF)
  end

  def update
    debug "in update with params #{params[:id]}"
    case params[:id]
    when 'Blue', 'Desert', 'Forest', 'Silver'
      predefined params[:id]
    else
      @color = Color.find(params[:id])
      debug "changes #{@color.name} from #{@color.value} to #{params[:color]}"
      colors = Rails.root.join('app','views','setup','color','colors.erb')
      debug "color file is #{colors}"
      colors_css = Rails.root.join('public', 'stylesheets', 'colors.css')
      debug "output file is #{colors_css.to_s}"
      if @color.update_attributes(:value => params[:color])
	flash[:notice] = "Color #{@color.name} was successfully updated."
	debug 'update successful'
	color_string = render_to_string(:layout => false, :file => colors.to_s)
	debug color_string
	File.delete(colors_css.to_s)
	file = File.new(colors_css.to_s, "w+")
	file.puts color_string
	file.close
      else
	flash[:error] = 'Update of color failed.'
      end
    end
    redirect_to setup_color_index_url
  end

  private

  def predefined( color )
    # set colors to one of the sets
    case color
    when 'Blue'
      [ {:name => 'body_background', :value => 'WhiteSmoke'},
	{:name => 'main_background', :value => 'WhiteSmoke'},
	{:name => 'columns_background', :value => 'LightSteelBlue'},
	{:name => 'banner_background', :value => 'MediumSlateBlue'},
	{:name => 'explain_background', :value => 'White'} ].each do |c|
	color = Color.find_by_name c[:name]
	debug "updating #{c[:name]} with #{c[:value]}"
	color.update_attributes :value => c[:value]
      end
    when 'Desert'
      [ {:name => 'body_background', :value => 'PaleGoldenRod'},
	{:name => 'main_background', :value => 'PaleGoldenRod'},
	{:name => 'columns_background', :value => 'Khaki'},
	{:name => 'banner_background', :value => 'GoldenRod'},
	{:name => 'explain_background', :value => 'PaleGoldenRod'} ].each do |c|
	color = Color.find_by_name c[:name]
	debug "updating #{c[:name]} with #{c[:value]}"
	color.update_attributes :value => c[:value]
      end
    when 'Forest'
      [ {:name => 'body_background', :value => 'MintCream'},
	{:name => 'main_background', :value => 'MintCream'},
	{:name => 'columns_background', :value => 'LightGreen'},
	{:name => 'banner_background', :value => 'DarkGreen'},
	{:name => 'explain_background', :value => 'MintCream'} ].each do |c|
	color = Color.find_by_name c[:name]
	debug "updating #{c[:name]} with #{c[:value]}"
	color.update_attributes :value => c[:value]
      end
    when 'Silver'
      [ {:name => 'body_background', :value => 'WhiteSmoke'},
	{:name => 'main_background', :value => 'WhiteSmoke'},
	{:name => 'columns_background', :value => 'Silver'},
	{:name => 'banner_background', :value => 'SlateGray'},
	{:name => 'explain_background', :value => 'WhiteSmoke'} ].each do |c|
	color = Color.find_by_name c[:name]
	debug "updating #{c[:name]} with #{c[:value]}"
	color.update_attributes :value => c[:value]
      end
    end
    [ {:name => 'body', :value => 'Black'},
      {:name => 'main', :value => 'Black'},
      {:name => 'columns', :value => 'Black'},
      {:name => 'banner', :value => 'Black'},
      {:name => 'late', :value => 'Black'},
      {:name => 'late_background', :value => 'Yellow'},
      {:name => 'locale', :value => 'Black'},
      {:name => 'locale_background', :value => 'White'},
      {:name => 'occupied', :value => 'Black'},
      {:name => 'occupied_background', :value => 'LimeGreen'},
      {:name => 'overstay', :value => 'Black'},
      {:name => 'overstay_background', :value => 'LightGray'},
      {:name => 'reserved', :value => 'Black'},
      {:name => 'reserved_background', :value => 'LightSteelBlue'},
      {:name => 'today', :value => 'DarkRed'},
      {:name => 'today_background', :value => 'Khaki'},
      {:name => 'notice', :value => 'Green'},
      {:name => 'notice_background', :value => 'Snow'},
      {:name => 'error', :value => 'Red'},
      {:name => 'error_background', :value => 'Snow'},
      {:name => 'warning', :value => 'Yellow'},
      {:name => 'warning_background', :value => 'Snow'},
      {:name => 'user', :value => 'Black'},
      {:name => 'unavailable', :value => 'Black'},
      {:name => 'unavailable_background', :value => 'Red'},
      {:name => 'unconfirmed', :value => 'Blue'},
      {:name => 'this_day', :value => 'Black'},
      {:name => 'this_day_background', :value => 'lightGreen'},
      {:name => 'link', :value => 'Black'},
      {:name => 'hover', :value => 'White'},
      {:name => 'payment_due', :value => 'Red'},
      {:name => 'ip_editor_field_background', :value => 'White'} ].each do |c|
      color = Color.find_by_name c[:name]
      color = Color.create :name => c[:name] if color == nil
      debug "updating #{c[:name]} with #{c[:value]}"
      color.update_attributes :value => c[:value]
    end
    colors = Rails.root.join('app','views','setup','color','colors.erb').to_s
    colors_css = Rails.root.join('public', 'stylesheets', 'colors.css')
    color_string = render_to_string(:layout => false, :file => colors.to_s)
    File.delete(colors_css.to_s)
    file = File.new(colors_css.to_s, "w+")
    file.puts color_string.to_s
    file.close
  end

end

