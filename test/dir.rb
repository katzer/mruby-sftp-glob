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

class Symbol
  def to_proc
    ->(obj, *args, &block) { obj.__send__(self, *args, &block) }
  end
end

SFTP.start('test.rebex.net', 'demo', password: 'password') do |sftp|
  assert 'SFTP::Dir#[]' do
    entries = sftp.dir['/**/example/*.png']

    assert_kind_of Array, entries
    assert_true entries.any?

    entries.each { |e| assert_kind_of SFTP::Entry, e }
    entries.each { |e| assert_equal '.png', e.name[-4..-1] }

    assert_equal '/', entries.first.name[0] if entries.any?

    assert_equal sftp.dir['pub/**/*.png'].map(&:name), \
                 sftp.dir['pub/example/*.png'].map(&:name)
  end

  assert 'SFTP::Dir#glob' do
    entries = sftp.dir.glob('**/*{client,editor}.png', ::File::FNM_EXTGLOB)

    assert_kind_of Array, entries
    assert_true entries.any?

    entries.each { |e| assert_kind_of SFTP::Entry, e }
    entries.each { |e| assert_equal '.png', e.name[-4..-1] }

    assert_true entries.first.name[0] != '/' if entries.any?
  end
end
