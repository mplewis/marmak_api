module ConfigDSL
  def defif(*syms)
    syms.map { |sym| defif1 sym }.join "\n"
  end

  def defval(*syms)
    syms.map { |sym| defval1 sym }.join "\n"
  end

  def defvalraw(*syms)
    syms.map { |sym| defvalraw1 sym }.join "\n"
  end

  def defvalif(*syms)
    syms.map { |sym| defvalif1 sym }.compact.join "\n"
  end

  def defcontents(*syms)
    syms.map { |sym| defcontents1 sym }.join "\n"
  end

  def defcontentsif(*syms)
    syms.map { |sym| defcontentsif1 sym }.compact.join "\n"
  end

  private

  def up(sym)
    sym.to_s.upcase
  end

  def defif1(sym)
    "#define #{up sym}" if @params[sym]
  end

  def defval1(sym)
    "#define #{up sym} #{@params[sym].inspect}"
  end

  def defvalraw1(sym)
    "#define #{up sym} #{@params[sym]}"
  end

  def defvalif1(sym)
    defval1(sym) if @params[sym]
  end

  def defcontents1(sym)
    "#define #{up @params[sym]}"
  end

  def defcontentsif1(sym)
    defcontents1(sym) if @params[sym]
  end
end
