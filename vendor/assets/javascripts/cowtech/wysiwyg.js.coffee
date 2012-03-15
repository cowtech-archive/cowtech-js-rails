###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.wysiwyg =
		cols: 5
		colors: ["FCE94F", "EDD400", "C4A000", "FCAF3E", "F57900", "CE5C00", "E9B96E", "C17D11", "8F5902", "8AE234", "73D216", "4E9A06", "729FCF", "3465A4", "204A87", "AD7FA8", "75507B", "5C3566", "EF2929", "CC0000", "A40000", "FFFFFF", "D3D7CF", "BABDB6", "888A85", "555753", "000000"]
		emotes: ["angel", "angry", "aww", "aww_2", "blushing", "childish", "confused", "creepy", "crying", "cthulhu", "cute", "cute_winking", "devil", "gah", "gah_2", "gasping", "greedy", "grinning", "grinning_winking", "happy", "happy_2", "happy_3", "heart", "huh", "huh_2", "kissing", "laughing", "lips_sealed", "madness", "malicious", "sick", "smiling", "speechless", "spiteful", "stupid", "sunglasses", "terrified", "thumb_down", "thumb_up", "tired", "tongue_out", "tongue_out_laughing", "tongue_out_left", "tongue_out_up", "tongue_out_up_left", "tongue_out_winking", "uncertain", "uncertain_2", "unhappy", "winking"]
		labels:
			preview: "Preview"
			remove: "Remove"
			url: "URL (Address)"
			alt: "Alternative text"
			title: "Title"
			placeholder: "Placeholder"
			bold: "Bold"
			italic: "Italic"
			underline: "Underline"
			strike_through: "Strikethrough"
			image: "Image"
			link: "Link"
			size: "Size"
			color: "Color"
			emote: "Emoticon"
			header_1: "Header 1"
			header_2: "Header 2"
			header_3: "Header 3"
			header_4: "Header 4"
			header_5: "Header 5"
			header_6: "Header 6"
			center: "Center"
			list: "List"
			ordered_list: "Ordered list"
			quote: "Quote"
		loader:
			message: "Loading ..."
			image: "/images/loading.gif"

		autoload: (->
			$("[data-wysiwyg-role=editor]").each(->
				$(this).closest("tr").removeClass("mandatory")
				$.cowtech.wysiwyg.setup $(this)
			)
		)

		show_preview: (->
			$("[data-wysiwyg-role=preview]").removeClass("loading")
			$("[data-wysiwyg-role=body]").slideDown("fast")
			$("[data-wysiwyg-role=loader]").remove()
		)

		preview: ((obj) ->
			area = $(obj.textarea)
			content = area.val()

			$("[data-wysiwyg-role=remove]").click()
			$("[data-wysiwyg-role=preview]").remove()

			prev = $("<div data-wysiwyg-role=\"preview\" class=\"loading\"><h2>#{$.cowtech.wysiwyg.labels.preview}<a href=\"#\" data-wysiwyg-role=\"remove\" class=\"btn btn-secondary\">#{$.cowtech.wysiwyg.labels.remove}</a></h2></div>")
			area.after(prev)
			$("<img data-wysiwyg-role=\"loader\" src=\"#{$.cowtech.wysiwyg.image}\" alt=\"#{$.cowtech.wysiwyg.loader.message}\"/>").appendTo(prev)
			$("[data-wysiwyg-role=remove]").on("click", ->
				$("[data-wysiwyg-role=preview]").remove()
				false
			)

			body = $("<iframe src=\"#\" data-wysiwyg-role=\"body\" id=\"wysiwyg-preview-body\"></iframe>").appendTo(prev).hide()
			form = $("<form action=\"#{$.cowtech.data.urls.preview}\" method=\"POST\" target=\"wysiwyg-preview-body\"><input type=\"hidden\" name=\"content\" value=\"\"/></form>")
			form.find("input").val(content)
			form.submit()
		)

		get_cell_info: ((cell, count, cols) ->
			cols = $.cowtech.utils.initialize(cols, $.cowtech.wysiwyg.cols)
			row_index = Math.floor(cell / cols) + 1
			col_index = Math.floor(cell % cols) + 1

			rv = ["row-#{row_index}", "col-#{col_index}"]
			rv.push("row-first") if row_index == 1
			rv.push("row-last") if row_index == Math.ceil(count / cols)
			rv.push("col-first") if col_index == 1
			rv.push("col-last") if col_index == cols
			rv
		)

		setup: ((el) ->
			wysiwyg_fonts = []
			i = 10

			# Add sizes
			while i < 40
				wysiwyg_fonts.push(name: "#{i}pt", openWith: "$", closeWith: "${: style=\"font-size: #{i}pt\"}", className: "font-cell wysiwyg-icon dimension")
				i += 2

			# Add colors
			wysiwyg_colors_buttons = []
			count = $.cowtech.wysiwyg.colors.length
			i = 0
			while i < count
				color = $.cowtech.wysiwyg.colors[i]
				wysiwyg_colors_buttons.push(openWith: "$", closeWith: "${: style=\"color: ##{color}\"}", className: "#{$.cowtech.wysiwyg.get_cell_info(i, count).join(" ")} color-cell color-#{color}")
				i++

			# Add buttons
			wysiwyg_emotes_buttons = []
			count = $.cowtech.wysiwyg.emotes.length
			i = 0
			while i < count
				emote = $.cowtech.wysiwyg.emotes[i]
				wysiwyg_emotes_buttons.push(replaceWith: "@#{emote}@", className: "#{$.cowtech.wysiwyg.get_cell_info(i, count).join(" ")} emotes-cell color-#{emote}")
				i++

			# Settings
			wysiwyg_settings =
				resizeHandle: false
				previewParserPath: ""
				onShiftEnter:
					keepDefault: false
					openWith: "\n\n"
				markupSet: [
					{name: $.cowtech.wysiwyg.labels.bold, key: "B", openWith: "**", closeWith: "**", className: "wysiwyg-icon bold"},
					{name: $.cowtech.wysiwyg.labels.italic, key: "I", openWith: "_", closeWith: "_", className: "wysiwyg-icon italic"},
					{name: $.cowtech.wysiwyg.labels.underline, key: "U", openWith: "=", closeWith: "=", className: "wysiwyg-icon u"},
					{name: $.cowtech.wysiwyg.labels.strike_through, key: "S", openWith: "~", closeWith: "~", className: "wysiwyg-icon s"},
					{separator: "---------------"},
					{name: $.cowtech.wysiwyg.labels.image, key: "P", replaceWith: "![[![#{$.cowtech.wysiwyg.labels.alt}]!]]([![#{$.cowtech.wysiwyg.labels.url}: !: http: //]!] \"[![#{$.cowtech.wysiwyg.labels.title}]!]\")", className: "wysiwyg-icon img"},
					{name: $.cowtech.wysiwyg.labels.link, key: "L", openWith: "[", closeWith: "]([![#{$.cowtech.wysiwyg.labels.url}: !: http: //]!] \"[![#{$.cowtech.wysiwyg.labels.title}]!]\")", placeHolder: $.cowtech.wysiwyg.labels.placeholder, className: "wysiwyg-icon link"},
					{separator: "---------------"},
					{name: $.cowtech.wysiwyg.labels.size, key: "D", className: "wysiwyg-icon dimension", dropMenu: wysiwyg_fonts},
					{name: $.cowtech.wysiwyg.labels.color, key: "T", className: "wysiwyg-icon color", dropMenu: wysiwyg_colors_buttons},
					{name: $.cowtech.wysiwyg.labels.emote, key: "E", className: "wysiwyg-icon emotes", dropMenu: wysiwyg_emotes_buttons},
					{separator: "---------------"},
					{name: $.cowtech.wysiwyg.labels.header_1, key: "1", openWith: "# ", className: "wysiwyg-icon h1"},
					{name: $.cowtech.wysiwyg.labels.header_2, key: "2", openWith: "## ", className: "wysiwyg-icon h2"},
					{name: $.cowtech.wysiwyg.labels.header_3, key: "3", openWith: "### ", className: "wysiwyg-icon h3"},
					{name: $.cowtech.wysiwyg.labels.header_4, key: "4", openWith: "#### ", className: "wysiwyg-icon h4"},
					{name: $.cowtech.wysiwyg.labels.header_5, key: "5", openWith: "##### ", className: "wysiwyg-icon h5"},
					{name: $.cowtech.wysiwyg.labels.header_6, key: "6", openWith: "###### ", className: "wysiwyg-icon h6"},
					{separator: "---------------"},
					{name: $.cowtech.wysiwyg.labels.center, key: "H", openWith: "%%%\n", closeWith: "\n%%%", className: "wysiwyg-icon center"},
					{name: $.cowtech.wysiwyg.labels.list, openWith: "- ", className: "wysiwyg-icon ul"},
					{name: $.cowtech.wysiwyg.labels.ordered_list, openWith: ((markItUp) -> "#{markItUp.line}. "), className: "wysiwyg-icon ol"},
					{name: $.cowtech.wysiwyg.labels.quote, openWith: "> ", className: "wysiwyg-icon quote"},
					{separator: "---------------"},
					{name: $.cowtech.wysiwyg.labels.preview, beforeInsert: $.cowtech.wysiwyg.preview, className: "wysiwyg-icon preview"}
				]

			el.markItUp(wysiwyg_settings)
		)
)(jQuery)
