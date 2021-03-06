###
Presentz.org - A website to publish presentations with video and slides synchronized.

Copyright (C) 2012 Federico Fissore

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

"use strict"

DemoScroller =

  displayItemNumber: 3
  itemNumber: 0

  init: () ->
    DemoScroller.resize()

    DemoScroller.itemNumber = $("#content_slider li.box4").length
    DemoScroller.createNav() if DemoScroller.itemNumber > DemoScroller.displayItemNumber

  createNav: () ->
    $("#slider").append("<div id=\"navigation_slider\"></div>")
    $("#navigation_slider").append("<ul></ul>")
    numLi = Math.ceil(DemoScroller.itemNumber / DemoScroller.displayItemNumber)

    $navigation_slider_ul = $("#navigation_slider ul")
    for i in [0...numLi]
      item = $("<li><a href=\"#/demopage/#{(i + 1)}\" rel=\"#{i}\"></a></li>")
      $navigation_slider_ul.append(item)

    ulWidth = (parseInt($("#navigation_slider ul li:first").width()) + parseInt($("#navigation_slider ul li:first").css("marginLeft").replace("px", "") * 2)) * numLi
    $navigation_slider_ul.css("width", ulWidth + "px")

    $navigation_slider_ul_li_a = $("#navigation_slider ul li a")
    $navigation_slider_ul_li_a.unbind("click").bind "click", (e) ->
      e.preventDefault()
      $navigation_slider_ul_li_a.removeClass()
      $this = $(this)
      $this.addClass("active")
      DemoScroller.moveScroll(parseInt($this.attr("rel")))

    $("a", "#navigation_slider ul li:first").trigger("click")

  moveScroll: (value) ->
    $("#content_slider").stop(true, false).animate({"left": -(value * $("#slider").width())}, 1200, "easeInOutQuart")

  resize: () ->
    return if $("#content_slider").length is 0

    $content_slider_li_box4 = $("#content_slider li.box4")
    content_slider_w = $content_slider_li_box4.length * parseInt(parseInt($content_slider_li_box4.css("width").replace("px", "")) + (parseInt($content_slider_li_box4.css("margin-left").replace("px", "")) * 2))
    $("#content_slider").css("width", content_slider_w)

    $("#navigation_slider ul li a.active").click()
    
resolution_notice_span_timeout = null

resolution_notice_span_on_resize = () ->
  $window = $(window)
  $resolution_notice_span = $("#resolution_notice span")
  if $window.height() > $window.width()
    $resolution_notice_span.text("Try flipping your device.")
  else
    $resolution_notice_span.text("")

set_timeout_of_resolution_notice_span_on_resize = () ->
  clearTimeout(resolution_notice_span_timeout)
  resolution_notice_span_timeout = setTimeout(resolution_notice_span_on_resize, 30)

$().ready () ->
  resolution_notice_span_on_resize()
  
  if $("#home").length > 0
    $h1_a_menu_ul_li_a = $("h1 a, #menu ul li:first-child a")
    $h1_a_menu_ul_li_a.unbind("click").bind "click", (e) ->
      e.preventDefault()
      $.scrollTo.window().queue([]).stop()
      $.scrollTo 0, 1200,
        easing: "easeInOutQuart"
        offset:
          top: 0

    $play_home = $("#ico_play_home")
    $play_home.unbind("click").bind "click", () ->
      document.location = "/r/talks.html"

  $link_demos_link_learn_more = $("#link_demos, .link_demos, #link_learn_more, #link_make_your_own, .link_make_your_own")
  $link_demos_link_learn_more.unbind("click").bind "click", (e) ->
    href = $(e.target).attr("href")
    if href.indexOf("/") is 0
      href = href.substr(1)
    if $(href).length > 0
      e.preventDefault()
      $.scrollTo.window().queue([]).stop()
      $.scrollTo href, 1200,
        easing: "easeInOutQuart",
        offset:
          top: -60

  $link_login_link_in_comment = $("#link_login, #link_login_in_comment, #link_login_hp")
  $link_login_link_in_comment.unbind("click").bind "click", (e) ->
    e.preventDefault()
    $("#login:not(:visible)").fadeIn("slow")

  $content_login_close = $("#content_login .close")
  $content_login_close.unbind("click").bind "click", (e) ->
    e.preventDefault()
    $("#login:visible").fadeOut("fast")

  #SEARCH INPUT
  $(".search input:first").each ->
    $this = $(this)
    $this.data "default", $this.val()
    $this.focus () ->
      $this.val("") if $this.val() is $this.data("default")

    $this.blur () ->
      $this.val $.trim($this.val())
      $this.val $this.data("default") if $this.val() is $this.data("default") || $this.val() is ""

  $(".search form").submit () ->
    value = $(".search input:first").val()
    pattern = /[ ,\n,\r]/g
    if value.replace(pattern, "").length > 0
      alert("SEARCHING: " + value)

  #SCROLLER DEMO
  DemoScroller.init() if $("#content_slider").length > 0

  $window = $(window)
  $window.unbind("resize").bind "resize", () ->
    DemoScroller.resize()
    set_timeout_of_resolution_notice_span_on_resize()  

  if document.location.search is "?access_denied"
    $link_login_link_in_comment.click()

  if document.location.hash.indexOf("#make_your_own") isnt -1 and $(document.location.hash).length > 0
    make_your_own_scroll_fix = () ->
      $(window).scrollTop($(document.location.hash).offset().top - 60)

    setTimeout(make_your_own_scroll_fix, 30)
    make_your_own_scroll_fix()

  return