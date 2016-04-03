#!/usr/bin/env ruby

require 'formula'

module Homebrew extend self
  HOMEBREW_ORPHANS_USAGE = <<-EOS.undent
    Usage: brew orphans
  EOS

  def orphans
    abort HOMEBREW_ORPHANS_USAGE if ARGV.first == '--help' || ARGV.first == '-h'

    installed_formulae_1 = Formula.installed
    installed_formulae_2 = installed_formulae_1.dup
    orphans = []

    installed_formulae_1.each do |queried_formula|
      found = false

      installed_formulae_2.each do |installed_formula|
        if installed_formula != queried_formula
          installed_formula.recursive_dependencies.to_a.each do |dependency|
            if dependency.installed? && dependency.name == queried_formula.name
              found = true
              break
            end
          end
        end
      end

      orphans << queried_formula unless found
    end

    puts orphans
  end
end

Homebrew.orphans
