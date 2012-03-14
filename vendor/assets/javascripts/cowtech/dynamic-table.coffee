###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.dynamic_table =
		reverse_index: false
		add_on_empty: true
		callbacks:
			added: []
			removed: []
			cleared: []
			updated: []

		autoload: (->
			$("[data-dynamic-table-role=root]").cowtech_dynamic_table()
		)

		on_added: ((root, row) ->
			$.each($.cowtech.dynamic_table.callbacks.added, (index, callback) ->
				callback(root, row)
			)
		)

		on_removed: ((root, row) ->
			$.each($.cowtech.dynamic_table.callbacks.removed, (index, callback) ->
				callback(root, row)
			)
		)

		on_cleared: ((root) ->
			$.each($.cowtech.dynamic_table.callbacks.cleared, (index, callback) ->
				callback(root)
			)
		)

		on_updated: ((root) ->
			$.each($.cowtech.dynamic_table.callbacks.updated, (index, callback) ->
				callback(root)
			)
		)

		get_table: ((root) ->
			root.find("[data-dynamic-table-role=body]")
		)

		get_rows: ((root) ->
			root.find("[data-dynamic-table-role=row]")
		)

		size: ((root) ->
			$.cowtech.dynamic_table.get_table(root).find("[data-dynamic-table-role=row]").size()
		)

		update_index: ((root) ->
			index = $.cowtech.utils.initialize(root.data("dynamic-table-row-index"), 0)
			index++
			root.data("dynamic-table-row-index", index)
			index
		)

		update: ((root) ->
			size = $.cowtech.dynamic_table.size(root)
			table = $.cowtech.dynamic_table.get_table(root)
			rows = table.find("[data-dynamic-table-role=row]")
			root.find("[data-dynamic-table-role=summary]").text(size)

			rows.each(->
				new_index = rows.index($(this)) + 1
				new_index = size - new_index + 1 if $.cowtech.dynamic_table.reverse_index
				$(this).find("[data-dynamic-table-role=index]").text(new_index)
			)

			if size > 0
				table.closest("[data-dynamic-table-role=table]").show()
			else
				table.closest("[data-dynamic-table-role=table]").hide()

			$.cowtech.numeric.autoload()
			table.find("[data-dynamic-table-attr-type=numeric]").cowtech_numeric()
			table.find("[data-dynamic-table-attr-type=date]").cowtech_date()
			table.find("[data-dynamic-table-attr-type=combobox]").combobox()
			root.closest("form").cowtech_form()

			$.cowtech.dynamic_table.on_updated(root)
		)

		add: ((root, prepend) ->
			table = $.cowtech.dynamic_table.get_table(root)
			tr = root.find("[data-dynamic-table-role=base]").clone()
			index = $.cowtech.dynamic_table.update_index(root)
			tr.attr("data-dynamic-table-role", "row")

			if prepend is true
				tr.prependTo(table)
			else
				tr.appendTo(table)

			tr.collapsible() if $.cowtech.utils.is_mobile()
			tr.find("[data-dynamic-table-role=index]").text(index)

			# Setup field id and name
			tr.find("[data-dynamic-table-field=true]").each(->
				field = $(this)
				name = field.attr("name").replace("_INDEX", "[" + index + "]")
				id = name.replace(/\[|\]/g, "_").replace(/__/, "_").replace(/_$/, "")
				field.attr(
					id: id
					name: name
				)
			)

			# Required fields
			tr.find("[data-dynamic-table-required=true]").each(->
				$(this).attr "required", "true"
			)

			tr.find("[data-dynamic-table-validate]").each(->
				$(this).attr "validate", $(this).attr("data-dynamic-table-validate")
			)

			# Callback
			$.cowtech.dynamic_table.on_added(root, tr)
			$.cowtech.dynamic_table.update(root)
			tr
		)

		remove: ((root, row, skip_events) ->
			row.remove()

			if skip_events != true
				$.cowtech.dynamic_table.on_removed(root, row)
				$.cowtech.dynamic_table.update(root)
		)

		clear: ((root) ->
			$.cowtech.dynamic_table.get_rows(root).each(->
				$.cowtech.dynamic_table.remove(root, $(this), true)
			)

			$.cowtech.dynamic_table.on_cleared(root)
			$.cowtech.dynamic_table.update(root)
		)

	$.fn.cowtech_dynamic_table = (->
		the_event = (if $.cowtech.utils.is_mobile() then "tap" else "click")

		$("[data-dynamic-table-role=root]").on(the_event, "[data-dynamic-table-role=delete]", (ev) ->
			$.cowtech.dynamic_table.remove $(this).closest("[data-dynamic-table-role=root]"), $(this).closest("[data-dynamic-table-role=row]")
			false
		)

		@each(->
			root = $(this)
			root.find("[data-dynamic-table-role=add]").on(the_event, (ev) ->
				$.cowtech.dynamic_table.add(root)
				false
			)

			root.find("[data-dynamic-table-role=clear]").on(the_event, (ev) ->
				$.cowtech.dynamic_table.clear(root)
				false
			)

			root.data("dynamic-table-row-index", $.cowtech.dynamic_table.size(root) + 1)
			root.find("[data-dynamic-table-role=row]").collapsible() if $.cowtech.utils.is_mobile()

			if $.cowtech.dynamic_table.size(root) == 0 && $.cowtech.dynamic_table.add_on_empty
				$.cowtech.dynamic_table.add(root)
			else
				$.cowtech.numeric.autoload()

			root.find("[data-dynamic-table-role=row]").each(->
				$.cowtech.dynamic_table.on_added root, $(this)
			)

			$.cowtech.dynamic_table.update(root)
		)
	)
)(jQuery)
