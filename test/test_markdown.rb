#!/usr/bin/env ruby
require_relative '../ftplugin/markdown'
require 'test/unit'

class TestMarkdown < Test::Unit::TestCase
public
  def test_surround_one_word
    assert_toggle_marker '**', 'abc def ghi', 'abc **def** ghi',
                               '    ^      ', '      ^        '

    assert_toggle_marker '**', 'abc def ghi', 'abc **def** ghi',
                               '     ^     ', '       ^       '

    assert_toggle_marker '**', 'abc def ghi', 'abc **def** ghi',
                               '      ^    ', '        ^      '
  end

  def test_surround_one_word_ignores_previous_markup
    assert_toggle_marker '**', '**ab** c def ghi', '**ab** c **def** ghi',
                               '          ^     ', '            ^       '
  end

  def test_surround_one_word_ignores_following_markup
    assert_toggle_marker '**', 'abc def g **hi**', 'abc **def** g **hi**',
                               '     ^          ', '       ^            '
  end

  def test_unsurround_one_word
    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '    ^          ', '    ^      '

    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '     ^         ', '    ^      '

    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '      ^        ', '    ^      '

    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '       ^       ', '     ^     '

    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '        ^      ', '      ^    '

    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '         ^     ', '      ^    '

    assert_toggle_marker '**', 'abc **def** ghi', 'abc def ghi',
                               '          ^    ', '      ^    '
  end

  def test_unsurround_two_words
    assert_toggle_marker '**', 'abc **def ghi** jkl', 'abc def ghi jkl',
                               '     ^             ', '    ^          '

    assert_toggle_marker '**', 'abc **def ghi** jkl', 'abc def ghi jkl',
                               '        ^          ', '      ^        '

    assert_toggle_marker '**', 'abc **def ghi** jkl', 'abc def ghi jkl',
                               '             ^     ', '          ^    '
  end

  def test_unsurround_without_end
    assert_toggle_marker '**', 'abc **def ghi', 'abc def ghi',
                               '     ^       ', '    ^      '

    assert_toggle_marker '**', 'abc **def ghi', 'abc def ghi',
                               '       ^     ', '     ^     '
  end

  def test_surround_in_presence_of_previous_segment
    assert_toggle_marker '**', 'abc **def**ghi jkl', 'abc **defghi** jkl',
                               '            ^     ', '          ^       '

    assert_toggle_marker '**', 'abc **def** ghi jkl', 'abc **def ghi** jkl',
                               '             ^     ', '           ^       '

    assert_toggle_marker '**', 'abc **def**   ghi jkl', 'abc **def   ghi** jkl',
                               '               ^     ', '             ^       '
  end

  def test_surround_in_presence_of_following_segment
    assert_toggle_marker '**', 'abc def**ghi** jkl', 'abc **defghi** jkl',
                               '     ^            ', '       ^          '

    assert_toggle_marker '**', 'abc def **ghi** jkl', 'abc **def ghi** jkl',
                               '     ^            ', '       ^          '

    assert_toggle_marker '**', 'abc def   **ghi** jkl', 'abc **def   ghi** jkl',
                               '     ^            ', '       ^          '
  end

  def test_surround_in_presence_of_previous_and_following_segments
    assert_toggle_marker '**', 'abc **def**-**ghi** jkl', 'abc **def-ghi** jkl',
                               '           ^           ', '         ^         '

    assert_toggle_marker '**', 'abc **def** **ghi** jkl', 'abc **def ghi** jkl',
                               '           ^           ', '         ^         '

    assert_toggle_marker '**', 'abc **def** xyz **ghi** jkl', 'abc **def xyz ghi** jkl',
                               '             ^             ', '           ^           '
  end

private
  def assert_toggle_marker marker, input, expected_output, input_pos, expected_output_pos
    input_pos = pos_string_to_number(input_pos)
    expected_output_pos = pos_string_to_number(expected_output_pos)

    output = input
    output_pos = Markdown.toggle_marker(output, input_pos, marker)

    assert_equal expected_output, output
    assert_equal output + "\n" + number_to_pos_string(expected_output_pos),
                 output + "\n" + number_to_pos_string(output_pos)
  end

  def pos_string_to_number pos
    pos.is_a?(Numeric) ? pos : pos.index('^')
  end

  def number_to_pos_string pos
    "#{' ' * pos}^"
  end
end
