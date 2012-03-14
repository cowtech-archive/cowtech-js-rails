# encoding: utf-8
#
# This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#


module CowtechJs
	class Engine < Rails::Engine	
		initializer "cowtech_js.add_assets_paths" do |app|
			app.config.assets.paths << File.dirname(__FILE__) + "/../vendor/assets/cowtech"
		end
	end
end
