#!/usr/bin/env ruby

require 'formula'

HOMEBREW_REVDEPS_USAGE = <<-EOS
Usage: brew revdeps <formula>
EOS

module Homebrew extend self
  def revdeps
    abort HOMEBREW_REVDEPS_USAGE if ARGV.empty?

    queried_formulae = ARGV.map do |formula_name|
      begin
        queried_formula = Formula.factory(formula_name)
      rescue
        queried_formula = nil
      end

      odie "No formula available for #{Tty.red}#{formula_name}#{Tty.reset}" unless queried_formula
      odie "Formula #{Tty.red}#{formula_name}#{Tty.reset} is not installed" unless queried_formula.installed?

      queried_formula
    end

    installed_formulae = Formula.installed

    queried_formulae.each do |queried_formula|
      dependent_formulae = []

      installed_formulae.each do |installed_formula|
        if installed_formula != queried_formula
          installed_formula.recursive_dependencies.to_a.each do |dependency|
            dependent_formulae << installed_formula if dependency.installed? && dependency.name == queried_formula.name
          end
        end
      end

      dependent_formulae = dependent_formulae.uniq.join(' ')

      STDOUT.write "#{Tty.white}#{queried_formula}#{Tty.reset}: #{dependent_formulae}\n" unless dependent_formulae.empty?
    end
  end
end

Homebrew.revdeps
