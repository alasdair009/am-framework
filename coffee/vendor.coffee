# AM vendor functions
AM = AM || {}
AM.constants =
  regex: {
    email: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/
    tel: /^\+?([0-9]{2})\)?[-. ]?([0-9]{4})[-. ]?([0-9]{4})$/
  }
AM.global =
  forms: ->
    $('form[data-am-form]').each ->
      thisForm = $(this)
      thisForm.attr 'novalidate', 'novalidate'
      requiredFields = $('*[required]', thisForm)
      console.log requiredFields
      # Submitting the form
      thisForm.on 'submit', (ev) ->
        submitForm = true
        requiredFields.attr 'data-am-focus', true
        if requiredFields.length > 0
          # Loop through each required field and validate
          requiredFields.each ->
            thisField = $(this)
            console.log 'validating ' + thisField.attr 'id'
            if !AM.global.formFieldValidate (thisField)
              submitForm = false
            return
        if !submitForm
          ev.preventDefault()
          thisForm.removeClass 'am-form-error'
          thisForm.addClass 'am-form-error'
        else
          thisForm.removeClass 'am-form-error'
          thisSubmitButton = $('*[type=submit]', thisForm)
          thisSubmitButton.prop 'disabled', true
          thisSubmitButton.addClass 'am-button-submitting'

      requiredFields.each ->
        thisField = $(this)
        thisField.on 'change', ->
          thisField.attr 'data-am-focus', true
          AM.global.formFieldValidate thisField


  formFieldValidate: (field) ->
    fieldValue = field.val()
    fieldName = field.attr 'name'
    isValid = true
    switch field.prop 'nodeName'
      when 'INPUT'
        switch field.attr 'type'
          when 'text'
            if fieldValue == '' || fieldValue == null
              isValid = false
          when 'email'
            if fieldValue == '' || fieldValue == null
              isValid = false
            else
              if !AM.constants.regex.email.test fieldValue
                isValid = false
          when 'number'
            if fieldValue == '' || fieldValue == null
              isValid = false
            else
              fieldValue = parseInt fieldValue
              if typeof fieldValue != 'number'
                isValid = false
                console.log 'not a number'
                console.log fieldValue
          when 'radio'
            isValid = false
            $('input[type="radio"][name="' + fieldName + '"]').each ->
              if $(this).is ':checked' && isChecked = false
                isValid = true
          when 'tel'
            if fieldValue == '' || fieldValue == null
              isValid = false
            else
              if !AM.constants.regex.tel.test fieldValue
                isValid = false
      when 'TEXTAREA'
        if fieldValue == '' || fieldValue == null
          isValid = false

    errorMessage = field.next()
    if isValid
      errorMessage.attr 'data-am-form-error', ''
    else
      errorMessage.attr 'data-am-form-error', 'invalid'
      console.log errorMessage.data 'am-form-error'
    return isValid

  sassVarsToJs: ->
    # Create the element
    newElementId = 'AM-vars'
    metaElement = document.createElement('meta')
    metaElement.id = newElementId
    $('head').append metaElement

    # Find the element and associated styles
    newElement = $('#' + newElementId)[0]
    allStyles = window.getComputedStyle newElement
    rawString = allStyles.getPropertyValue 'content'

    # Sort out breakpoints
    AM.global.breakpoints = {}
    breakpoints = rawString.split ';'
    breakpoints.forEach (element)->
      thisPoint = element.split '='
      AM.global.breakpoints[thisPoint[0]] = thisPoint[1]

  videoAutoplay: (callback)->
    video = document.createElement 'video'
    video.paused = true
    play = 'play' of video && video.play()
    typeof callback == 'function' && callback !video.paused || 'Promise' of window && play instanceof Promise
    
  video: ->
    AM.global.videoAutoplay (supported) ->
      videos = $('*[data-am-video]')
      if supported
        videos.each ->
          thisElement = $(this)
          webmUrl = thisElement.data('am-video-webm')
          mp4Url = thisElement.data('am-video-mp4')
          sourceWebm = document.createElement('source')
          sourceMp4 = document.createElement('source')
          sourceWebm.type = 'video/webm'
          sourceMp4.type = 'video/mp4'
          sourceWebm.src = webmUrl
          sourceMp4.src = mp4Url

          thisElement.append sourceWebm
          thisElement.append sourceMp4
      else
        videos.remove()
  init: ->
    @forms()
    @sassVarsToJs()
    @video()

AM.onLoad =
  init: ->
    AM.global.init()

$(document).ready AM.onLoad.init()