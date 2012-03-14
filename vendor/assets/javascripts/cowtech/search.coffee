###
 #
 # This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
 # Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 #
###

(($) ->
	$.cowtech = $.cowtech || {}
	$.cowtech.search =
		execute: (->
			nv = $.extend($.cowtech.data.params.params, {
				page: 1
			})
			fnv = {}

			$("[data-search-field]").each(->
				key = $(this).attr("data-search-field")

				if !key.match(/^period-(month|year)$/)
					if $(this).is("[type=checkbox]")
						nv[key] = $(this).is(":checked")
					else
						nv[key] = $(this).val()
			)

			nv["period"] = "#{$("[data-search-field=period-year]").val()}-#{$("[data-search-field=period-month]").val()}"  if $("[data-search-field|=\"period\"]").size() == 2

			for key of nv
				fnv[key] = nv[key] if !$.cowtech.utils.is_blank(nv[key])
			location.href = "#{$.cowtech.data.params.current_location.replace(/#$/, "")}?#{$.param(fnv)}"
		)

		autoload: (->
			$("[data-search-field]:not([data-search-disabled=true])").on("change", $.cowtech.search.execute)
			$("[data-search-role=search]").on("click", $.cowtech.search.execute)
			$("[data-search-role=clear]").on("click", (ev) ->
				$("[data-search-field=search]").val("")
				$.cowtech.search.execute()
				false
			)
		)
)(jQuery)
