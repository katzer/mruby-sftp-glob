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
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module SFTP
  class Dir
    # Match (possibly recursively) all directory entries against pattern.
    #
    # @param [ String ] pattern The pattern to use for.
    # @param [ Int ]    flags   A bitwise OR of the File::FNM_XXX constants.
    #
    # @return [ Array<SFTP::Entry> ]
    def glob(pattern, flags = 0)
      flags  |= ::File::FNM_PATHNAME
      parts   = pattern.split('/')

      if pattern.include? '*'
        path = ''
        parts.each { |e| e.include?('*') ? (break) : path += e + '/' }
        patt = pattern[(path.length)..-1]
      else
        path = parts[0...-1].join('/')
        patt = pattern[(path.length + 1)..-1]
      end

      dirname = patt[0...(patt.rindex('/') || 0)]
      rpath   = path[-1] == '/' ? path[0...-1] : path
      parts   = dirname.split('/')
      queue   = entries(rpath).reject { |f| f.name == '.' || f.name == '..' }
      results = []

      while (e = queue.shift)
        results << e if ::File.fnmatch?(patt, e.name, flags)

        next unless e.directory?

        epath  = rpath.empty? ? e.name : "#{rpath}/#{e.name}"
        spatt  = parts[0, epath.split('/').size].join('/')

        next unless ::File.fnmatch(spatt, epath, flags) || \
                    ::File.fnmatch("#{spatt}/*", epath, flags)

        queue += entries(epath)
                 .reject { |f| f.name == '.' || f.name == '..' }
                 .each   { |f| f.name.replace("#{e.name}/#{f.name}") }
      end

      results.each { |f| f.name.replace "#{rpath}/#{f.name}" } unless path.empty?

      results
    end

    # Identical to calling glob with a flags parameter of 0 and no block.
    #
    # @param [ String ] pattern The pattern to use for.
    #
    # @return [ Array<SFTP::Entry> ] The matched entries as an array.
    def [](pattern)
      glob(pattern, 0)
    end
  end
end
