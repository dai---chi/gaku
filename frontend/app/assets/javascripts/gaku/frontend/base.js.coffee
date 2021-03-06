window.showNotice = (notice)->
  $('#notice').html(notice).delay(3000).fadeOut ->
    $(@).html('').show()

$.fn.enableValidations = ->
  $(this).enableClientSideValidations()

$.fn.withAnimation = ->
  $(this).animate({height:"toggle", opacity:"toggle"})

$.fn.showModal = ->
  $(this).modal('show')

$.fn.hideModal = ->
  $(this).modal('hide')

$.fn.gaku_select2 = (placeholder)->
  $(@).select2({ width: 'resolve', placeholder: placeholder }).removeClass('form-control')

$.fn.datepicker_i18n = ->
  $(this).datepicker({
       language: $('body').data('locale'),
       startView: 2,
       autoclose: true,
       todayBtn: true,
       todayHighlight: true,
       calendarWeeks: true
  })

$.fn.datepicker.defaults.format = "yyyy-mm-dd"

window.add_sortable = ->
  fixHelper = (e, ui) ->
    ui.children().each ->
      $(@).width $(@).width()
    ui

  $('.sortable').sortable
    handle: '.sort-handler'
    helper: fixHelper
    axis: 'y'
    update: ->
      $.post $(@).data('sort-url'), $(@).sortable('serialize')

window.load_states = ->
  countryCode = $("#country_dropdown option:selected").val()
  if countryCode
    $.ajax
      type: 'get'
      url: '/states_list'
      dataType: 'script'
      data:
        country_id: countryCode

window.load_edit_states = (state_id) ->
  countryCode = $("#country_dropdown option:selected").val()
  if countryCode
    $.ajax
      type: 'get'
      url: '/states_list'
      dataType: 'script'
      data:
        country_id: countryCode
        state_id: state_id

class App
  init: ->

    $('.datepicker').datepicker_i18n()

    $(document).on 'ajax:success', '.recovery-link', ->
      $(this).closest('tr').remove()

    $(document).on 'ajax:success','.delete-link', (evt, data, status, xhr) ->
      $(this).closest('tr').remove()

    notice = $('#notice')
    if notice.children().length > 0
      notice.children().delay(3000).fadeOut ->
        notice.html('')

    $('.modal-delete-link').on 'click', (e)->
      e.preventDefault()
      $('#delete-modal').modal('show')

    # sorting helper fixixing table row width when drag
    fixHelper = (e, ui) ->
      ui.children().each ->
        $(@).width $(@).width()
      ui

    $('.sortable').sortable
      handle: '.sort-handler'
      helper: fixHelper
      axis: 'y'
      update: ->
        $.post $(@).data('sort-url'), $(@).sortable('serialize')


  edit: ->
    @upload_picture()

    unless(typeof notable_resource == 'undefined')
      $("#submit-" + notable_resource + "-note-button").live "ajax:success", (data, status, xhr)->
        $("#new-" + notable_resource + "-note-link").show()
        $("#new-" + notable_resource + "-note form").slide()

    $('#soft-delete-link').on 'click', (e)->
      e.preventDefault()
      $('#delete-modal').modal('show')

  show: ->
    # FIXME Remove after view refactoring
    @edit()

  upload_picture: ->
    $(document).on 'click', '#upload-picture-link', ->
      $("#upload-picture").toggle()

  upload_picture_ajax: ->
    $('body').popover
      selector: '.picture-upload'
      html: true
      content: ()->
        return $('#upload-picture').html()
      placement: 'bottom'
      trigger: 'click'


  country_dropdown: ->
    $('body').on 'change', '#country_dropdown', ->
      window.load_states()

  student_chooser: ->
    $.ajax
      type: 'get'
      url: '/student_selection'
      dataType: 'script'

    $(document).on 'click', '#clear-student-selection', (e)->

      e.preventDefault()

      $.ajax
        type: 'get'
        url: '/student_selection/clear'
        dataType: 'script'

    $(document).on 'click', '.remove-student', ->
      thisId = $(this).closest('a').attr('id')

      $.ajax
        type: "POST",
        url: "/student_selection/remove",
        data: { id: thisId },
        dataType: 'script'

    $(document).on 'click', '.check-all', (e)->
      e.preventDefault()

      $checkboxes = $('.student-check')

      student_ids = []
      $('#students-index').find('tbody tr').map ->
        student_ids.push @id.split('-')[1]

      if $('.student-check:checked').length == $('.student-check').length
        $checkboxes.prop('checked', false)

        $.ajax
          type: "POST",
          url: "/student_selection/remove_collection",
          data: { 'student_ids': student_ids },
          dataType: 'script'

      else
        $checkboxes.prop('checked', true)

        $.ajax
          type: "POST",
          url: "/student_selection/collection",
          data: { 'student_ids': student_ids },
          dataType: 'script'

    $('body').on 'change', 'input.student-check', ->
      thisCheck = $(this)
      tr_id = $(this).closest('tr').attr('id')
      parsed_id = tr_id.split('student-')
      thisId = parsed_id[1]


      if thisCheck.is (':checked')
        $('#selected-students, #enroll-to-class-form, #enroll-to-course-form, #enroll-to-extracurricular-activity-form').append('<input type="hidden" name="selected_students[]" value="' + thisId + '" class="' + thisId + '"/>')

        $.ajax
          type: "POST",
          url: "/student_selection/add",
          data: { id: thisId },
          dataType: 'script'

      else
        $.ajax
          type: "POST",
          url: "/student_selection/remove",
          data: { id: thisId },
          dataType: 'script'


ready = ->

  @app = new App

  (($, undefined_) ->
    $ ->
      $body = $("body")
      parent_controller = $body.data("parent-controller")
      action = $body.data("action")


      @app.init()  if $.isFunction(@app.init)
      @app[action]()  if $.isFunction(@app[action])

      activeController = @app[parent_controller]
      if activeController isnt `undefined`
        activeController.init()  if $.isFunction(activeController.init)
        activeController[action]()  if $.isFunction(activeController[action])
  ) jQuery


$(document).ready(ready)
$(window).bind('page:change', ready)
