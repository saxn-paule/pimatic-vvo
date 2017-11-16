$(document).on( "templateinit", (event) ->
# define the item class

	class vvoDeviceItem extends pimatic.DeviceItem
		test = "<div>HALLO WELT</div>"

		constructor: (templData, @device) ->
			@id = @device.id
			super(templData,@device)

			@getAttribute('schedule').value.subscribe( (newval) =>
				$("#placeholder").html(newval)
			)


		afterRender: (elements) ->
			super(elements)
			return
	  
	# register the item-class
	pimatic.templateClasses['vvo'] = vvoDeviceItem
)