// ==UserScript==
// @namespace   bill-auger
// @name        lctv-chat
// @description Adds a visibility toggle and audience size indicator to LCTV chat roster and replaces emotes with the original ASCII
// @include     https://www.livecoding.tv/*/chat
// @version     1
// @grant       none
// ==/UserScript==


var WRAPPER_ID   = 'chat-rooms' ;
var CHAT_CSS     = 'room-pane' ;
var MESSAGES_CSS = 'message-pane' ;
var VIP_CLASS    = 'lctv-premium' ;
var ROSTER_CSS   = 'roster-pane' ;
var TOOLBAR_ID   = 'chat-toolbar' ;
var TOGGLE_ID    = 'chat-usercount' ;
var BADGE_URL    = "https://codiad-billauger.rhcloud.com/badges/?channel=bill-auger&style=" ;
var BADGE_STYLE  = 'n-viewers-v1' ;
var CHAT_W       = 80 ;  // '%'
var TOOLBAR_W    = 140 ; // pixels
var IMG_W        = 72 ;  // pixels


var Wrapper ;
var Chat ;
var Messages ;
var Toolbar ;
var Toggle ;
var ViewersImg ;
var Roster ;


function init()
{
  Wrapper  = document.getElementById        (WRAPPER_ID  ) ;
  Chat     = document.getElementsByClassName(CHAT_CSS    )[0] ;
  Messages = document.getElementsByClassName(MESSAGES_CSS)[0] ;
  Toolbar  = document.getElementById        (TOOLBAR_ID  ) ;
  Toggle   = document.getElementById        (TOGGLE_ID   ) ;
  Roster   = document.getElementsByClassName(ROSTER_CSS  )[0] ;
  if (!Wrapper || !Chat || !Messages || !Toolbar || !Toggle || !Roster)
  { window.setTimeout(init , 1000) ; return ; }

console.log("lctv-chat userscript - ready") ;

  // manipulate roster pane
  showRoster() ; createStatusImg() ; updateViewers() ;
  window.setInterval(updateViewers , 60000) ;

  // manipulate chat messages and register change listener
  handleChat(Messages.getElementsByTagName('li')) ;
  observeDOM(Messages , 'addedNodes' , handleChat) ;

console.log("lctv-chat userscript - done") ;
}


/* add status badge and visibilty toggle to roster pane */

function showRoster()
{
  function toggleRoster()
  {
    var is_collapsed = Roster.style.display == 'none' ;

    Chat.style.width = ((is_collapsed) ? CHAT_W : 100) + '%' ;
  }


  Chat  .style.width           = CHAT_W + '%' ;
  Toggle.onclick               = toggleRoster ;
  Roster.style.display         = 'block' ;
  Roster.style.left            = 'unset' ;
  Roster.style.top             = '24px' ;
  Roster.style.right           = '0px' ;
  Roster.style.bottom          = '90px' ;
  Roster.style.width           = '20%' ;
  Roster.style.backgroundColor = '#22252D' ;

  Wrapper.appendChild(Roster) ;
}

function createStatusImg()
{
  ViewersLi  = document.createElement('li') ;
  ViewersImg = document.createElement('img') ;

  Toolbar   .style.width     = (TOOLBAR_W + IMG_W) + 'px' ;
  ViewersLi .style.width     = IMG_W + 'px' ;
  ViewersImg.style.width     = IMG_W + 'px' ;
  ViewersImg.style.height    = "16px" ;
  ViewersImg.style.marginTop = "6px" ;

  Toolbar  .appendChild(ViewersLi ) ;
  ViewersLi.appendChild(ViewersImg) ;
}

function updateViewers()
{
  var nonce = "&" + (new Date()).getTime() ;
  ViewersImg.src = BADGE_URL + BADGE_STYLE + nonce ;

// console.log("updating=" + BADGE_URL + BADGE_STYLE + nonce) ;
}


/* observe DOM and normalize messages */

function observeDOM(interesting_element , interesting_event , callback) // aNode , aString , aFunction
{
  function addMutationObserver(interesting_element , interesting_event , callback)
  {
  console.log("adding MutationObserver") ;

    var mutation_type     = (interesting_event == 'addedNodes') ? 'childList' : null ;
    var observer_class    = window.MutationObserver || window.WebKitMutationObserver ;
    var mutation_observer = new observer_class(function(mutations , observer)
    {
      mutations.forEach(function(mutation)
      {
        if (mutation.type == mutation_type) callback(mutation.addedNodes) ;
      }) ;
    }) ;

    mutation_observer.observe(interesting_element , { childList: true }) ;
  }

  function addEventListener(interesting_element , interesting_event , callback)
  {
  console.log("adding EventListener") ;

    interesting_element.addEventListener('DOMNodeInserted' , callback , false) ;
  }


  var is_mutation_observer_supported = !!window.MutationObserver      ||
                                       !!window.WebKitMutationObserver ;
  var is_event_listener_supported    = !!window.addEventListener ;

  if      (is_mutation_observer_supported)
    addMutationObserver(interesting_element , interesting_event , callback) ;
  else if (is_event_listener_supported   )
    addEventListener   (interesting_element , interesting_event , callback) ;
}

function handleChat(addedNodes) // aNodeList
{
console.log("handling chat message event") ;

  for (var message_li_n = 0 ; message_li_n < addedNodes.length ; ++message_li_n)
  {
    var message_li       = addedNodes[message_li_n] ;
    var nick_a           = message_li.getElementsByTagName('a')[0] ;
    var emote_imgs       = message_li.getElementsByTagName('img') ;
    var colon            = document.createElement('span') ;
    colon.textContent    = ":" ;
    colon.style.position = 'relative' ;
    colon.style.left     = '-5px' ;

    // replace VIP badge with acii
    if (~message_li.className.indexOf(VIP_CLASS))
    {
      message_li.classList.toggle(VIP_CLASS) ;
      nick_a.appendChild(document.createTextNode(" [VIP]")) ;
    }

    // replace emotes with acii
    for (var emote_img_n = 0 ; emote_img_n < emote_imgs.length ; ++emote_img_n)
    {
      var emote_img = emote_imgs[emote_img_n] ;
      var alt_text  = document.createTextNode(emote_img.alt) ;

      emote_img.parentNode.replaceChild(alt_text , emote_img) ;
    }

    // add colon to message entry
    message_li.insertBefore(colon , nick_a.nextSibling) ;
  }
}


console.log("lctv-chat userscript - waiting for DOM") ;

window.onload = init ;
