class ApplicationController < ActionController::API
  # hashes containing callback names and options are class instance variables
  # if not set yet, they are initialized in their getters
  def self.bef_callback_hsh
    @bef_callback_hsh ||= Hash.new([])
  end

  def self.aft_callback_hsh
    @aft_callback_hsh ||= Hash.new([])
  end

  # filters support the 'only' optional hash to select actions preceded/followed by callbacks
  def self.before_aktion(callback, only_hash = nil)
    bef_callback_hsh[callback] += only_hash && only_hash[:only] ? only_hash[:only] : []
  end

  def self.after_aktion(callback, only_hash = nil)
    aft_callback_hsh[callback] += only_hash && only_hash[:only] ? only_hash[:only] : []
  end

  def process(action, *args)
    # the action itself is preceded by the callbacks in bef_callback_hsh ...
    self.class.bef_callback_hsh.each do |cb, acts|
      send(cb) if acts.empty? || acts.include?(action.to_sym)
    end

    # ... then it's executed...
    send(action, *args)

    # ... and then followed by callbacks in aft_callback_hsh
    self.class.aft_callback_hsh.each do |cb, acts|
      send(cb) if acts.empty? || acts.include?(action.to_sym)
    end
  end
end
