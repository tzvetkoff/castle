#!/usr/bin/env ruby

#:  * `revdeps` <formula>
#:    Lists all installed packages that depend on <formula>.

require 'formula'

module Homebrew
  module_function

  def revdeps
    queried_formulae = ARGV.map do |formula_name|
      begin
        queried_formula = Formulary.factory(formula_name)
      rescue
        odie "No formula available for #{Tty.red}#{formula_name}#{Tty.reset}"
      end

      odie "Formula #{Tty.red}#{formula_name}#{Tty.reset} is not installed" unless queried_formula.installed?

      queried_formula
    end

    installed_formulae = Formula.installed

    queried_formulae.each do |queried_formula|
      dependent_formulae = []

      installed_formulae.each do |installed_formula|
        if installed_formula != queried_formula
          installed_formula.recursive_dependencies.each do |dependency|
            dependent_formulae << installed_formula if dependency.name == queried_formula.name
          end
        end
      end

      dependent_formulae = dependent_formulae.join(' ') #.uniq.join(' ')

      puts "#{Tty.reset.bold}#{queried_formula}#{Tty.reset}: #{dependent_formulae}\n" unless dependent_formulae.empty?
    end
  end
end

Homebrew.revdeps
