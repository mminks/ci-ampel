module WallSocket
  def toggle_green_light(status, options)
    case status
    when true
      switch = '-o'
    when false
      switch = '-f'
    else
      raise "toggle_green_light: I don't know what to do. Sorry!"
    end

    `sudo sispmctl #{switch} 1` unless options[:dry_run] == true
  end

  def toggle_red_light(status, options)
    case status
    when true
      switch = '-o'
    when false
      switch = '-f'
    else
      raise "toggle_red_light: I don't know what to do. Sorry!"
    end

    `sudo sispmctl #{switch} 2` unless options[:dry_run] == true
  end

  def toggle_siren(status, options)
    case status
    when true
      switch = '-o'
    when false
      switch = '-f'
    else
      raise "toggle_siren: I don't know what to do. Sorry!"
    end

    `sudo sispmctl #{switch} 3` unless options[:dry_run] == true
  end
end
