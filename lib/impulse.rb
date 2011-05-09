module Impulse
  class Graph
    attr_reader :debug
  
    def initialize(debug = false)
      @debug = debug
    end
    
    def push(name, datas, params = {})
      create_or_find_rrd(name, datas)
      push_to_rrd(name, datas)
    end
    
    def draw(name, time_scale = :day, params = {})
      params = { 
        :filename => 'impuse.png', 
        :height => 200, 
        :width => 600, 
        :title => 'Impuse Graph', 
        :vertical => '',
        :legend => ''
      }.merge(params)
      
      defaults = "-E -W 'Generated at #{Time.at(Time.now)}' -e now -h #{params[:height]} -w #{params[:width]}"
      cmd = ["rrdtool graph #{params[:filename]} -s -#{seconds_for(time_scale)} #{defaults} -t '#{params[:title]}' -v '#{params[:vertical]}'"]
      
      if name.is_a?(Hash)
        c = 0
        name.each do |k,v|
          v = { :color => '#FF0000', :data => :data }.merge(v)
          cmd << "DEF:d#{c}=#{v[:name]}.rrd:#{v[:data].to_s}:MAX"
          cmd << "LINE1:d#{c}#{v[:color]}:'#{k}' GPRINT:d#{c}:LAST:\"Last\\:%8.0lf\" GPRINT:d#{c}:MIN:\"	Min\\:%8.0lf\" GPRINT:d#{c}:AVERAGE:\"	Avg\\:%8.0lf\" GPRINT:d#{c}:MAX:\"	Max\\:%8.0lf\\n\""
          c += 1
        end
      else
        cmd << "DEF:average=#{name}.rrd:data:MAX"
        cmd << "LINE1:average#FF0000:'#{params[:legend]}' GPRINT:average:LAST:\"Last\\:%8.0lf\" GPRINT:average:MIN:\"	Min\\:%8.0lf\" GPRINT:average:AVERAGE:\"	Avg\\:%8.0lf\" GPRINT:average:MAX:\"	Max\\:%8.0lf\\n\""
      end

      system cmd.join(" ")
    end
    
    private
    def create_or_find_rrd(name, datas)
      averages = "RRA:AVERAGE:0.5:1:576 RRA:MIN:0.5:1:576 RRA:MAX:0.5:1:576 RRA:AVERAGE:0.5:6:432 RRA:MIN:0.5:6:432 RRA:MAX:0.5:6:432 RRA:AVERAGE:0.5:24:540 RRA:MIN:0.5:24:540 RRA:MAX:0.5:24:540 RRA:AVERAGE:0.5:288:450 RRA:MIN:0.5:288:450 RRA:MAX:0.5:288:450"
      unless File.exist?(name + ".rrd")
        puts 'Creating RRD' if @debug
        if datas.is_a?(Hash)
          entries = []
          datas.each do |k,v|
            entries << "DS:#{k.to_s}:GAUGE:600:0:U"
          end
          system "rrdtool create #{name}.rrd --step 300 --start #{Time.now.to_i - 1} #{entries.join(' ')} #{averages}"
        else
          system "rrdtool create #{name}.rrd --step 300 --start #{Time.now.to_i - 1} DS:data:GAUGE:600:0:U #{averages}"
        end
      end
    end
    
    def push_to_rrd(name, data)
      if File.exist?(name + ".rrd")
        puts 'Updating RRD' if @debug
        system "rrdtool update #{name}.rrd #{Time.now.to_i}:#{data}"
      end
    end
    
    def seconds_for(time_scale)      
      case time_scale
      when :hour
        3600
      when :day
        86400
      when :week
        604800
      when :month
        2629743
      when :year
        31556926
      else
        time_scale
      end
    end
  end
end
