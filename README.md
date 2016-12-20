# Vim Markup Assistant

This Vim plugin provides key bindings to quickly change marked-up text.

The Vim Markup Assistant focuses on **single-key actions**
that **toggle** the word or region underneath the cursor
rather than multi-key operator/movement combinations.

## Keys overview
| key           | functionality                                  |
| ------------- | ---------------------------------------------- |
| <kbd>F7</kbd> | toggles emphasis at the cursor position        |
| <kbd>F8</kbd> | toggles strong emphasis at the cursor position |

## Markdown
### Normal mode
<table>
<thead>
  <tr><th>before</th><th>key</th><th>after</th><th>description</th>
</thead>
<tbody>
  <tr>
    <td><code>abc <strong>d</strong>ef ghi jkl</code></td>
    <td><kbd>F8</kbd></td>
    <td><code>abc **<strong>d</strong>ef** ghi jkl</code></td>
    <td>emphasizes the word under the cursor</td>
  </tr>
  <tr>
    <td><code>abc **<strong>d</strong>ef ghi** jkl</code></td>
    <td><kbd>F8</kbd></td>
    <td><code>abc <strong>d</strong>ef ghi jkl</code></td>
    <td>removes emphasis on an already emphasized segment</td>
  </tr>
  <tr>
    <td><code>abc **def** <strong>g</strong>hi jkl</code></td>
    <td><kbd>F8</kbd></td>
    <td><code>abc **def <strong>g</strong>hi** jkl</code></td>
    <td>emphasizes the word, joining adjacent emphasis regions</td>
  </tr>
</tbody>
</table>


## Installation
This plugin requires Vim with Ruby support,
and can be installed with your favorite package manager.

For example, with [Plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'RubenVerborgh/vim-markup-assistant'
```

## Related packages
- **[vim-surround](https://github.com/tpope/vim-surround)** provides operators
  to easily (de-)surround pieces of text with arbitrary characters.
  In contrast to Vim Markup Assistant, it requires multiple keystrokes,
  does not join adjacent regions, and does not easily support `**` surroundings.
  Both plugins are compatible and complementary.

## License
[MIT License](https://opensource.org/licenses/MIT) –
Copyright © 2016–present Ruben Verborgh (https://ruben.verborgh.org/)
