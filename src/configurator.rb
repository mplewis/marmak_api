# frozen_string_literal: true

require 'active_support/core_ext/hash'
require 'erb'
require 'yaml'
require_relative 'lib/config_dsl'

class Configurator
  include ConfigDSL

  DIR = File.dirname __FILE__
  TEMPLATE_PATH = File.expand_path('data/Configuration.h.erb', DIR).freeze
  OPTIONS_PATH = File.expand_path('data/Configuration.h.options.yml', DIR).freeze

  TEMPLATE = File.open(TEMPLATE_PATH).read
  GENERATOR = ERB.new TEMPLATE
  OPTIONS = YAML.load_file(OPTIONS_PATH).deep_symbolize_keys.freeze
  DEFAULTS = OPTIONS.map { |k, v| [k, v[:default]] }.select { |_, v| v }.to_h

  MANDATORY = OPTIONS.select { |k, v| v[:mandatory] }.map(&:first).freeze
  BOOLEAN = OPTIONS.select { |k, v| v[:type] == 'boolean' }.map(&:first).freeze
  INTEGER = OPTIONS.select { |k, v| v[:type] == 'integer' }.map(&:first).freeze
  FLOAT = OPTIONS.select { |k, v| v[:type] == 'float' }.map(&:first).freeze

  INCLUSION = OPTIONS.select { |k, v| v[:options] }
                     .map { |k, v| [k, v[:options].map(&:first).map { |v| v&.to_s }] }
                     .to_h.freeze

  def self.generate(params)
    discovered_errors = errors(params)
    unless discovered_errors.empty?
      e = InvalidParamsError.new 'Invalid params'
      e.errors = discovered_errors
      raise e
    end
    new(params).generate
  end

  def self.errors(params)
    new(params).errors
  end

  def initialize(params)
    @params = DEFAULTS.merge(params).to_h.symbolize_keys
  end
  private_class_method :new

  def generate
    GENERATOR.result binding
  end

  def errors
    errors = Hash.new { |h, k| h[k] = [] }

    MANDATORY.each do |key|
      next if data.keys.include? key
      errors[key] << "Missing mandatory key #{key.inspect}"
    end

    BOOLEAN.each do |key|
      value = data[key]
      next unless value
      next if [true, false].include? value
      errors[key] << "Value for key #{key.inspect} must be true or false, got #{value.inspect}"
    end

    INTEGER.each do |key|
      value = data[key]
      next if value == value.try(:to_i)
      errors[key] << "Value for key #{key.inspect} must be an integer, got #{value.inspect}"
    end

    FLOAT.each do |key|
      value = data[key]
      next if value == value.try(:to_f) || value == value.try(:to_i)
      errors[key] << "Value for key #{key.inspect} must be a float, got #{value.inspect}"
    end

    INCLUSION.each do |key, expected_values|
      value = data[key]
      next unless value
      next if expected_values.include? value
      errors[key] << "Value for key #{key.inspect} must be one of #{expected_values.inspect}, got #{value.inspect}"
    end

    errors
  end

  private

  def data
    @params
  end

  class InvalidParamsError < StandardError
    attr_accessor :errors
  end
end
