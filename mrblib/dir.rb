# MIT License
#
# Copyright (c) 2018 Sebastian Katzer, appPlant GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module SFTP
  class Dir
    # Match (possibly recursively) all directory entries under path against
    # pattern. If a block is given, matches will be yielded to the block as they
    # are found; otherwise, they will be returned in an array when the method
    # finishes.
    #
    # @param [ String ] path    The path to test.
    # @param [ String ] pattern The pattern to use for.
    # @param [ Int ]    flags   A bitwise OR of the File::FNM_XXX constants.
    #
    # @return [ Array<SFTP::Entry> ] nil if block is given.
    def glob(path, pattern, flags = 0, &block)
      flags    |= ::File::FNM_PATHNAME
      queue     = entries(path).reject { |e| e.name == '.' || e.name == '..' }
      dirname   = pattern[0...(pattern.rindex('/') || 0)]
      results   = [] unless block

      while (entry = queue.shift)
        rpath = "#{path}#{'/' unless path.empty?}#{entry.name}"

        if ::File.fnmatch?(pattern, entry.name, flags)
          block ? yield(entry) : results << entry
        end

        next unless entry.directory? && ::File.fnmatch?(dirname, rpath, flags)

        queue += entries(rpath)
                 .reject { |e| e.name == '.' || e.name == '..' }
                 .each   { |e| e.name.replace("#{entry.name}/#{e.name}") }
      end

      results.each { |e| e.name.replace "#{path}/#{e.name}" unless path.empty? }
    end

    # Identical to calling glob with a flags parameter of 0 and no block.
    #
    # @param [ String ] path    The path to test.
    # @param [ String ] pattern The pattern to use for.
    #
    # @return [ Array<SFTP::Entry> ] The matched entries as an array.
    def [](path, pattern)
      glob(path, pattern, 0).to_a
    end
  end
end
