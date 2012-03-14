###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}

	$.cowtech.dynamic_table.add_on_empty = false

	$.cowtech.document =
		search_uri: ""
		advanced_search_uri: ""
		pending_row: null
		adding: false
		callbacks:
			searched: []
			added: []
			updated: []

		fields:
			label: "label"
			price: ""
			amount: ""
			off: ""
			decimal: ""
			precision: ""
			symbol: ""

		on_updated: ((root) ->
			return if $.cowtech.document.adding

			$.each($.cowtech.document.callbacks.updated, (index, callback) ->
				callback(root)
			)
		)

		on_added: ((root, row) ->
			$.each($.cowtech.document.callbacks.added, (index, callback) ->
				callback(root, row)
			)
		)

		on_searched: ((root, input, result) ->
			$.each($.cowtech.document.callbacks.searched, (index, callback) ->
				callback(root, input, result)
			)
		)

		autoload: (->
			$.cowtech.dynamic_table.reverse_index = true
			$.cowtech.document.get_root().cowtech_document()
		)

		get_root: (->
			$("[data-document-role=root]")
		)

		get_rows: ((root) ->
			root.find("[data-dynamic-table-role=row]")
		)

		row_subtotal: ((row) ->
			data = row.data("article")
			$.cowtech.document.subtotal(data.price, data.amount, data.off)
		)

		subtotal: ((price, amount, off_) ->
			$.cowtech.utils.round_number((amount * price) * (1 - (off_ / 100)), 2)
		)

		is_row_valid: ((row) ->
			!$.cowtech.utils.is_null(row.data("article"))
		)

		reset_search: ((root, row) ->
			row.find("[data-document-role=label]").addClass("unset").text("Nessuno")
			row.find("[data-document-role=insert] span.label").text("Cerca")
			row.find("[data-document-role=price]").val("0.00").numberize()
			row.find("[data-document-role=amount]").val("0.00").attr(
				"data-numeric-float": $.cowtech.data.params.unit.decimal
				"data-precision": $.cowtech.data.params.unit.precision
			).numberize()
			row.find("[data-document-role=amount]").next().html($.cowtech.data.params.unit.symbol)
			row.find("[data-document-role=off]").val("0.00").numberize()
			row.find("[data-document-role=code]").focus()
			row.find("[data-document-role=code]").focus()
		)

		start_external_search: ((root, row, query) ->
			$.cowtech.document.pending_row = row
			link = root.find("[data-document-role=search]").attr("href").replace("?", "?query=#{encodeURIComponent(query)}&")
			$.cowtech.modal.open(link, {
				scrolling: "no"
			})
		)

		end_external_search: ((code) ->
			row = $.cowtech.document.pending_row
			$.cowtech.document.pending_row = null
			row = $.cowtech.document.get_root().find("[data-dynamic-table-role=base]") if !row?
			row.find("[data-document-role=code]").val(code).focus().change()
		)

		search: ((root, input) ->
			value = input.val()
			row = input.closest("tr")

			if !$.cowtech.utils.is_blank(value)
				row.find("[data-document-role=label]").addClass("unset").text("Ricerca in corso ...")
				row.removeData("article")

				$.ajax(
					url: $.cowtech.document.search_uri
					data:
						codice: value
					success: ((data, text, xhr) ->
						if data.valid
							article = data.data
							fields = $.cowtech.document.fields

							# Set data
							row.data("article", article)
							row.find("[data-document-role=code]").val(article[fields.code])
							row.find("[data-document-role=label]").removeClass("unset").text(article[fields.label])

							# Set unit
							row.find("[data-document-role=amount]").attr(
								"data-numeric-float": (if !$.cowtech.utils.is_blank(article[fields.decimal]) then article[fields.decimal] else $.cowtech.data.params.unit.decimal)
								"data-numeric-precision": (if !$.cowtech.utils.is_blank(article[fields.precision]) then article[fields.precision] else $.cowtech.data.params.unit.precision)
							).numberize()
							row.find("[data-document-role=amount]").next().html(if !$.cowtech.utils.is_blank(article[fields.symbol]) then article[fields.symbol] else $.cowtech.data.params.unit.symbol)

							# Set button, if present
							if row.is("[data-dynamic-table-role=base]")
								row.find("[data-document-role=insert] span.label").text("Aggiungi")
								row.find("[data-document-role=price]").val(article[fields.price])
								row.find("[data-document-role=amount]").val(article[fields.amount])
								row.find("[data-document-role=off]").val(article[fields.off])
								setTimeout((->
									row.find("[data-document-role=amount]").focus()
								), 300)
						else
							row.find("[data-document-role=label]").text("Nessuno")
							query = row.find("[data-document-role=code]").val()
							$.cowtech.document.reset_search(root, row) if row.is("[data-dynamic-table-role=base]")
							$.cowtech.document.start_external_search(root, row, query)

						$.cowtech.document.on_searched(root, input, data)
					)
					error: ((xhr, text, error) ->
						$.cowtech.messages.alert("error", "Impossibile cercare l'articolo.")
					)
				)
		)

		add: ((root) ->
			base = root.find("[data-dynamic-table-role=base]")

			base.find("[data-dynamic-table-attr-type=numeric]").each(->
				$(this).numberize()
			)

			$.cowtech.document.adding = true
			base.find("[data-document-role=amount]").val(1).change().numberize() if base.find("[data-document-role=amount]").data("numeric-value") == 0
			row = $.cowtech.dynamic_table.add(root.find("[data-dynamic-table-role=root]"), true)

			# Copy data
			row.data("article", base.data("article"))
			base.removeData("article")

			# Reset search
			base.find("[data-document-role=insert] span.label").text("Verifica")
			base.find("[data-document-role=code]").val("")
			base.find("[data-document-role=label]").text("")

			# Modify button
			row.find("[data-document-role=insert]").remove()
			row.find("[data-dynamic-table-role=clear]").attr("data-dynamic-table-role", "delete").text("Rimuovi")

			$.cowtech.document.on_added(root, row)
			$.cowtech.document.adding = false
			$.cowtech.document.on_updated(root)
			$.cowtech.document.reset_search(root, base)
		)

		update: ((root) ->
			$("[data-dynamic-table-role=table]").show()
			$.cowtech.document.on_updated(root)
		)

	$.fn.cowtech_document = (->
		$.cowtech.dynamic_table.callbacks.updated.push((root) ->
			$.cowtech.document.update(root)
		)

		$.tools.validator.fn("[validate=article]", (el, value) ->
			(if !$.cowtech.utils.is_null(el.closest("tr").data("article")) then true else
				it: "Articolo non valido"
				en: "Invalid article"
			)
		)

		@each(->
			root = $(this)
			root.find("[data-dynamic-table-role=base]").show()
			$.cowtech.dynamic_table.update(root.find("[data-dynamic-table-role=root]"))

			$("body").on("change", "[data-document-role=root] input", (ev) ->
				return  if $.cowtech.document.adding

				el = $(this)
				if el.is("[data-document-role=code]")
					$.cowtech.document.search(root, $(this))
				else
					$.cowtech.document.update(root)
			)

			$("body").on("keypress", "[data-document-role=root] input", (ev) ->
				el = $(this)
				row = $(this).closest("tr")

				if ev.keyCode == 13
					if el.is("[data-document-role=code]")
						if row.is("[data-dynamic-table-role=base]") && $.cowtech.document.is_row_valid(row)
							$.cowtech.document.add(root)
						else
							$.cowtech.document.search(root, $(this))
					else
						if row.is("[data-dynamic-table-role=base]") && $.cowtech.document.is_row_valid(row)
							$.cowtech.document.add(root)
						else
							el.parent().next("td").find("input").focus()

					false
			)

			$("[data-document-role=insert]").on("click", (ev) ->
				row = $(this).closest("tr")

				if $.cowtech.document.is_row_valid(row)
					$.cowtech.document.add(root)
				else
					$.cowtech.document.search(root, row)

				false
			)
		)
	)
)(jQuery)
