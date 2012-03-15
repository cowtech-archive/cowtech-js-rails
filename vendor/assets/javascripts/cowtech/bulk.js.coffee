###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.bulk =
		action: null
		button: null
		label: null

		update: ->
			count = $("[data-bulk-role=single]:checked").size()
			if $.cowtech.bulk.label
				text = $.cowtech.bulk.label.text().replace(/(\(\d+\))?:$/, "").trim()
				if count > 0
					text += " <b>(#{count})</b>:"
				else
					text += ":"
				$.cowtech.bulk.label.html(text)

			if count > 0
				$.cowtech.bulk.button.show()
			else
				$.cowtech.bulk.button.hide()

		autoload: ->
			$.cowtech.bulk.action = $("[data-bulk-role=action]")
			$.cowtech.bulk.label = $.cowtech.bulk.action.prev("label")
			$.cowtech.bulk.button = $("[data-bulk-role=execute]")
			$("[data-bulk-role=all]").on("change", ->
				if $(this).is(":checked")
					$(this).closest("table").find("[data-bulk-role=single]").attr("checked", "checked")
				else
					$(this).closest("table").find("[data-bulk-role=single]").removeAttr("checked")
				$.cowtech.bulk.update()
			)

			$("[data-bulk-role=single]").on("change", ->
				$.cowtech.bulk.update()
				false
			)

			$.cowtech.bulk.action.on("change", ->
				$("[date-bulk-role=date]").css "display", (if $(this).val() == "change-" then "inline" else "none")
				false
			).change()

			$.cowtech.bulk.button.on("click", (ev) ->
				action = $.cowtech.bulk.action.val()

				if !$.cowtech.utils.is_blank(action)
					ids = []
					$("[data-bulk-role=single]:checked").each ->
						ids.push $(this).attr("id").replace("select-", "")

					if ids.length > 0
						action += "#{$("select#change-year-field").val()}-#{$("select#change-month-field").val()}"  if action == "change-"
						uri = $.param(
							bulk_action: action
							ids: ids.join(",")
						)
						location.href = "#{$.cowtech.data.params.bulk_url}?#{uri}"
				false
			)

			$.cowtech.bulk.update()
)(jQuery)
