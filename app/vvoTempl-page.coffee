$(document).on( "templateinit", (event) ->
# define the item class
	class vvoDeviceItem extends pimatic.DeviceItem
		constructor: (templData, @device) ->
			@id = @device.id
			super(templData,@device)

		afterRender: (elements) ->
			super(elements)

			@getAttribute('schedule').value.subscribe( (newval) =>
				$("#"+@id+"_vvo_placeholder").html(newval)
			)

			return
			
	# register the item-class
	pimatic.templateClasses['vvo'] = vvoDeviceItem
)