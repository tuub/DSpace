// BaseURI for correct Subject Linking
var itemPageBaseUrl  = location.href.split( 'handle/' )[0];

jQuery.fn.extend({
    hasClasses: function( selector ) {
       var classNamesRegex = new RegExp("( " + selector.replace(/ +/g,"").replace(/,/g, " | ") + " )"),
           rclass = /[\n\t\r]/g,
           i = 0,
           l = this.length;
       for ( ; i < l; i++ ) {
           if ( this[i].nodeType === 1 && classNamesRegex.test((" " + this[i].className + " ").replace(rclass, " "))) {
               return true;
           }
       }
       return false;
   }
});

var headID = document.getElementsByTagName("head")[0];

+function ($) {

  'use strict';

  $( document ).ready(function() {

    /*
    headID.appendChild(tooltipsterJS);
    headID.appendChild(tablesorterJS);
    headID.appendChild(easytreeJS);
    headID.appendChild(tooltipsterCSS);
    headID.appendChild(tablesorterCSS);
    headID.appendChild(easytreeCSS);
    */

    /*
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    | DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    */

    /************************************************************************
    * Metadata Display First TD Fixed Width
    ************************************************************************/
    $('td.metadataFieldLabel').css('width', '15%');

    /************************************************************************
    * Extra Bottom Paddings for all tables
    ************************************************************************/
    //$('table tr').css('padding-bottom', '10px');

    /************************************************************************
    * Add <thead> wrapper to tables with <th>
    ************************************************************************/
    var tables = $('table');
    tables.each( function(){
        var thisTable = $(this);
        var theads = thisTable.find("thead");
        var theadrows =  thisTable.find("tr:has(th)");

        if (theads.length == 0)
        {
            theads = $('<thead></thead>').addClass('header').prependTo(thisTable);
        }
        theadrows.clone(true).appendTo( theads );
        theadrows.remove();
    });

    /************************************************************************
    * All H1s to H2s
    ************************************************************************/
    /*
    $('h1, h3').replaceWith(function(){
        return $("<h2 />").append( $(this).text() );
    });
    */

    /************************************************************************
    * Remove all Well-Container
    ************************************************************************/
    $('.well').removeClass('well');

    /************************************************************************
    * Remove all paddings in nested containers
    ************************************************************************/
    //$('.container>.container').addClass('nopadding');


    /************************************************************************
    * Move Help Buttons beside to the right & hide (for now)
    ************************************************************************/
    //$('h1, h2').has('span.glyphicon-question-sign').children('a').wrap('<span class="pull-right"></span>');

    /************************************************************************
    * Hide Help Buttons (for now)
    ************************************************************************/
    $('h1, h2, .panel-heading').has('span.glyphicon-question-sign').find('span.glyphicon-question-sign').hide();

    /************************************************************************
    * Remove unneccessary classes and empty class attributes
    ************************************************************************/
    $('td, th').removeClass('evenRowEvenCol evenRowOddCol oddRowOddCol oddRowEvenCol');
    $('*[class=""]').removeAttr('class');

    /************************************************************************
    * Set default value for all panel-headings (instead of primary value)
    ************************************************************************/
    $('div.panel').filter('.panel-primary').removeClass('panel-primary').addClass('panel-default');
    $('.panel-info').removeClass('panel-info').addClass('panel-default');

    /************************************************************************
    * Remove "Help on Subject Categories" link in Submission Form
    ************************************************************************/
    $('div.help-block').children().find('a').remove();
    $('div.help-block').children().find('noscript').remove();

    /************************************************************************
    * Move "Subject Categories" selection link to preceding div.help-block
    ************************************************************************/
    var $controlledVocabularyLink = $('span.controlledVocabularyLink').parent();
    var $helpBlock = $('span.controlledVocabularyLink').parent().closest('div.row');
    //$controlledVocabularyLink.appendTo( $helpBlock );
    //console.log( $helpBlock ); // .appendTo('div.help-block')

    /************************************************************************
    * Adjust Facets to fit (except responsive boxes)
    ************************************************************************/
    $('.facetsBox').children().filter(function() { return this.className.match((/(^|\s)col-\S+/g)) }).css('padding','0');
    $('.facetsBox').children('.panel').removeClass('panel-success').addClass('panel-default');
    $('.facetsBox').removeClass('row panel').children('.facet').removeClass('col-md-12').addClass('panel panel-default');
    $('.facetsBox').find('span.facetName').replaceWith(function(){
        return $('<div class="panel-heading">').append($(this).contents());
    });

    /************************************************************************
    * Remove bottom copyright text from item view pages
    ************************************************************************/
    $('p.submitFormHelp.alert.alert-info').hide();

    /************************************************************************
    * Remove Handle from Item Display, show only DOI
    ************************************************************************/
    var handleLink = $('td.metadataFieldValue a').filter(function() {
        var link = $(this).attr('href');
        return link.match(/\.tu\-berlin\.de\/handle\//);
    });
    $(handleLink).next('br').remove();
    $(handleLink).remove();

    /************************************************************************
    * Adjust Admin Boxes and Action Boxes to fit
    ************************************************************************/
    var $adminPanelBox = $('div.panel-warning > div.panel-heading:contains("Admin")').parent();
    $adminPanelBox.removeClass('panel-warning').addClass('panel-default facets');
    $adminPanelBox.find('.panel-body > form').wrap('<ul class="list-group"></ul>').children('input.btn').removeClass('col-md-12 btn-default').addClass('btn-link').wrap('<li class="list-group-item"></li>');

    var $actionsPanelBox = $('div.panel-default > div.panel-heading:contains("Actions")').parent();
    $actionsPanelBox.addClass('facets');
    $actionsPanelBox.find('.panel-body > form').wrap('<ul class="list-group"></ul>').children('input.btn').removeClass('col-md-12 btn-default').addClass('btn-link').wrap('<li class="list-group-item"></li>');

    /************************************************************************
    * Adjust Language Code Labels
    ************************************************************************/
    if( $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language:'; }).size() == 0 )
    {
        var $languageCode = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).next();
        if( undefined != $languageCode.html() )
        {
            var languageCodeReplacer = "";
            if( $languageCode.html().indexOf("<br>") > -1)
            {
                var languageCodeParts = $languageCode.html().split('<br>');
            }
            else
            {
                var languageCodeParts = new Array( $languageCode.html() );
            }
            for( var i=0; i < languageCodeParts.length; i++ )
            {
                switch ( languageCodeParts[i] )
                {
                    case "de":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "German";
                        break;
                    case "en":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "English";
                        break;
                    case "fr":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "French";
                        break;
                    case "sp":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Spanish";
                        break;
                    case "zh":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Chinese";
                        break;
                    case "it":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Italian";
                        break;
                    case "ja":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Japanese";
                        break;
                    case "fa":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Persian";
                        break;
                    case "pl":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Polish";
                    case "pt":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Portugese";
                        break;
                    case "el":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Greek";
                        break;
                    case "tr":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Turkish";
                        break;
                    case "und":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Other";
                        break;
                    default:
                        languageCodeReplacer += $languageCode.html();
                };
                if( i < languageCodeParts.length-1 )
                {
                    languageCodeReplacer += '<br/>';
                }
            }

            $languageCode.html( languageCodeReplacer );
        };
    }
    else
    {
        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).next().remove();
        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).remove();
    };


      /************************************************************************
    * Adjust Type Version Labels (not used)
    ************************************************************************/
    var $typeVersion = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Version of published item:'; }).next();
    if( $typeVersion )
    {
        var typeVersionReplacer = "";
        switch ( $typeVersion.text() )
        {
            case "draft":
                typeVersionReplacer = "Draft Version";
                break;
            case "submittedVersion":
                typeVersionReplacer = "Submitted Version";
                break;
            case "acceptedVersion":
                typeVersionReplacer = "Accepted Version";
                break;
            case "publishedVersion":
                typeVersionReplacer = "Published Version";
                break;
            case "updatedVersion":
                typeVersionReplacer = "Updated Version";
                break;
            default:
                typeVersionReplacer = "Unknown Version";
        };
        $typeVersion.text( typeVersionReplacer );
    };

    /************************************************************************
    * Adjust Abstract Display
    ************************************************************************/
    var $abstractField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Abstract:'; }).next();
    if( $abstractField.size() > 0 )
    {
        var abstractsHTML = $abstractField.html();
        if( abstractsHTML !== null )
        {
            abstractsHTML = abstractsHTML.split("<br>").join("<hr class=\"splitter\" />");
            abstractsHTML = abstractsHTML.replace(/\r/g, "<br/><br/>");
        }
        $abstractField.html( abstractsHTML );
    }

    /************************************************************************
    * Adjust Notes Display
    ************************************************************************/
    var $notesField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Notes:'; }).next();
    if( $notesField.size() > 0 )
    {
      var notesHTML = $notesField.html();
      if( notesHTML !== null )
      {
          notesHTML = notesHTML.replace(/\r/g, "<br/>");
      }
      $notesField.html( notesHTML );
    }

    /************************************************************************
    * Add URN Linking
    ************************************************************************/
    $('td.metadataFieldValue a').filter( function() { return this.text.match(/urn/); } ).each( function(){
        $(this).attr( 'href', 'http://nbn-resolving.de/' + $(this).text() );
    });

    /************************************************************************
    * Add DOI Linking
    ************************************************************************/
    $('td.metadataFieldValue').each( function(){
        var $this = $(this);
        var links = $this.children().filter('a');
        //var pattern = /10\.[0-9]+\/[0-9a-zA-Z-]+/;
        var pattern = /10\.[0-9.]+\/[0-9a-zA-Z-.]+/;
        var resolver = 'https://doi.org/';

        if( links.length > 0 ) {
            links.each(function(index) {
                var currentLink = $(this);
                if( pattern.test(currentLink.text()) ) {
                    /* Kick out any existing resolver parts from link, use only ours above */
                    var currentDOI = currentLink.attr('href').replace(/(^\w+:|^)\/\/[a-z\.\/]*/, '');
                    /* Update actual link */
                    currentLink.attr('href', resolver + currentDOI).attr('target', '_blank').text(currentDOI);
                };
            });
        };
    });

      /************************************************************************
       * Add Subject Linking
       ************************************************************************/
      var $subjectField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Subject(s):'; }).next();
      if( $subjectField.size() > 0 )
      {
          var subjectsHTML = String();
          var subjectSearchURI = itemPageBaseUrl + 'browse?type=subject&order=ASC&rpp=20&value=';
          var subjects = $subjectField.html().split('<br>');
          subjects.forEach(function(subject) {
              subjectsHTML += '<a href="' + subjectSearchURI + subject + '">' + subject + '</a><br/>';
          });
          $subjectField.html(subjectsHTML);
      }

      /************************************************************************
       * Adjust DDC Display (since Configuration doesn't work)
       * Add DDC Class Linking
       ************************************************************************/
      var $ddcClassField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'DDC Class:'; }).next();
      if( $ddcClassField.size() > 0 )
      {
          var ddcClassesHTML = String();
          var ddcClassSearchURI = itemPageBaseUrl + 'browse?type=subject&order=ASC&rpp=20&value=';
          var ddcClasses = $ddcClassField.html().split('<br>');
          ddcClasses.forEach(function(ddcClass) {
              var ddcValue = ddcClass.split('::').slice(-1)[0];
              ddcClassesHTML += '<a href="' + ddcClassSearchURI + ddcClass + '">' + ddcValue + '</a><br/>';
          });
          $ddcClassField.html(ddcClassesHTML);
      }

    /************************************************************************
    * Nicer License / DC.RIGHTS.URI Display
    ************************************************************************/
    var $licenseField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'License:'; }).next();
    var licenseUri = $licenseField.text();
    var licenseList = {
        'apache2': {
          'label': 'Apache License 2.0',
          'uri': 'https://choosealicense.com/licenses/apache-2.0/'
        },
        'bsd-2': {
          'label': 'BSD License (BSD-2-Clause)',
          'uri': 'https://choosealicense.com/licenses/bsd-2-clause/'
        },
        'bsd-3': {
          'label': 'BSD License (BSD-3-Clause)',
          'uri': 'https://choosealicense.com/licenses/bsd-3-clause/'
        },
        'cc': {
          'label': 'Creative Commons',
          'uri': 'https://creativecommons.org/licenses/'
        },
        'cc0': {
          'label': 'Creative Commons Zero',
          'uri': 'https://creativecommons.org/publicdomain/'
        },
        'copyright': {
          'label': 'In Copyright',
          'uri': 'http://rightsstatements.org/vocab/InC/1.0/'
        },
        'gpl-2': {
          'label': 'GNU General Public License 2.0 (GNU GPLv2)',
          'uri': 'https://choosealicense.com/licenses/gpl-2.0/'
        },
        'gpl-3': {
          'label': 'GNU General Public License 3.0 (GNU GPLv3)',
          'uri': 'https://choosealicense.com/licenses/gpl-3.0/'
        },
        'lgpl-21': {
          'label': 'GNU Lesser General Public License 2.1 (GNU LGPLv2.1)',
          'uri': 'https://choosealicense.com/licenses/lgpl-2.1/'
        },
        'lgpl-3': {
          'label': 'GNU Lesser General Public License 3.0 (GNU LGPLv3)',
          'uri': 'https://choosealicense.com/licenses/lgpl-3.0/'
        },
        'mit': {
          'label': 'MIT License',
          'uri': 'https://choosealicense.com/licenses/mit/'
        },
        'mozilla': {
          'label': 'Mozilla Public License 2.0 (MPL)',
          'uri': 'https://choosealicense.com/licenses/mpl-2.0/'
        }
    };

    if( licenseUri !== null ) {
        Object.keys(licenseList).forEach(function(key) {
            var license = licenseList[key];
            var label = license['label'];
            var uri = license['uri'].toLowerCase();

            if(licenseUri.toLowerCase().indexOf(uri) >= 0) {
                switch(key) {
                    case 'cc':
                        var licenseInfo = licenseUri.split("https://creativecommons.org/licenses/").join("");
                        if( licenseInfo.slice(-1) == '/') {
                            licenseInfo = licenseInfo.slice(0, -1);
                        }

                        var licenseString = 'Creative Commons ' + licenseInfo.split('/').join(' ').toUpperCase();
                        var licenseImage = '<img src="https://i.creativecommons.org/l/' + licenseInfo.split(' ').join('/') + '/88x31.png" alt="' + licenseString + '" title="' + licenseString + '" />';
                        $licenseField.html(licenseImage).wrapInner(function() {
                            return '<a rel="license" href="' + licenseUri + '" target="_blank"></a>';
                        });
                        $licenseField.append( '&nbsp;&nbsp;&nbsp;<a rel="license" href="' + licenseUri + '" target="_blank">' + licenseString + '</a>');
                        break;
                    case 'cc0':
                        var licenseInfo = licenseUri.split("https://creativecommons.org/publicdomain/").join("");
                        if( licenseInfo.slice(-1) == '/') {
                            licenseInfo = licenseInfo.slice(0, -1);
                        }
                        var licenseString = 'Creative Commons ' + licenseInfo.split('/').join(' ').toUpperCase();
                        if (licenseString.toLowerCase().indexOf(" mark ") >= 0) {
                            licenseString = 'Public Domain Mark';
                        }
                        var licenseImage = '<img src="https://i.creativecommons.org/l/' + licenseInfo.split(' ').join('/') + '/88x31.png" alt="' + licenseString + '" title="' + licenseString + '" />';
                        if (licenseImage.toLowerCase().indexOf("mark") >= 0) {
                            licenseImage = 'https://licensebuttons.net/p/88x31.png';
                        }
                        $licenseField.html(licenseImage).wrapInner(function() {
                            return '<a rel="license" href="' + licenseUri + '" target="_blank"></a>';
                        });
                        $licenseField.append( '&nbsp;&nbsp;&nbsp;<a rel="license" href="' + licenseUri + '" target="_blank">' + licenseString + '</a>');
                        break;
                    case 'copyright':
                        var licenseInfo = licenseUri.split('http://rightsstatements.org/vocab/').join('');
                        if( licenseInfo.slice(-1) == '/') {
                            licenseInfo = licenseInfo.slice(0,3);
                        }
                        /* Logo with text */
                        var licenseImage = '<img src="' + itemPageBaseUrl + '/image/' + licenseInfo + '.Icon-Only.dark.png" style="height: 21px;">';
                        $licenseField.html(licenseImage).wrapInner(function() {
                            return '<a rel="license" href="' + licenseUri + '" target="_blank"></a>';
                        });
                        $licenseField.append( '&nbsp;&nbsp;&nbsp;<a rel="license" href="' + licenseUri + '" target="_blank">' + label + '</a>');
                        break;
                    default:
                        $licenseField.html(label).wrapInner(function() {
                            return '<a rel="license" href="' + licenseUri + '" target="_blank"></a>';
                        });
                }
            }
        });
    }

    /************************************************************************
    * Button Colors based on values in their name/id attributes
    ************************************************************************/

    // All Buttons To Default State
    $('input.btn').not('.btn-link').not('.btn-success').removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');

    /*
    $('input.btn').not('.btn-link').removeClass (function (index, css) { return (css.match (/(^|\s)col-\S+/g) || []).join(' ') });
    $('input.btn-info').removeClass('btn-info').addClass('btn-default');

    // Success States
    //$('input.btn').not('.btn-link').filter( function() { return this.name.match(/submit/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/resume/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');

    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/update/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/upload/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/next/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/retry/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/perform/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/claim/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/search/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.id.match(/main-query-submit/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');

    // Danger States
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/cancel/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-danger');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/delete/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-danger');

    // Default States
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/view/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/edit/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/close/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/own/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/return/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/clear/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    */

    // All Link Buttons To Default State
    $('a.btn').removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default btn-xs').css('font-weight', 'normal');

    /************************************************************************
    * Smaller Buttons
    ************************************************************************/
    $('td .btn').addClass('btn-xs');
    $('.btn-sm').removeClass('btn-sm').addClass('btn-xs');
    $('#browse_navigation input.btn, #browse_controls input.btn, .discovery-search-form .btn').addClass('btn-xs');

    /************************************************************************
    * Group Edit Buttons Rearrangement FIXME! HACK!
    ************************************************************************/
    $('form[name=epersongroup] div.row').removeClass('container').css( 'margin-left', '0' ).css( 'margin-right', '0' );

    /************************************************************************
    * Center button groups
    ************************************************************************/
    $('input.btn').not('.btn-link').removeClass (function (index, css) { return (css.match (/(^|\s)col-\S+/g) || []).join(' ') });
    $('div.row').has('div.btn-group').find('div.btn-group')
    .removeClass('btn-group').removeClass('pull-right').addClass('text-center').removeClass(function (index, css) { return (css.match (/(^|\s)col-\S+/g) || []).join(' ') });

    /************************************************************************
    * Panel-Bodys to every panel
    ************************************************************************/
    $('div.panel-heading').next().filter(':not(.panel-body)').wrap('<div class="panel-body" />');

    /*
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    | FEATURES FEATURES FEATURES FEATURES FEATURES FEATURES FEATURES FEATURES
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    */

    /************************************************************************
    * On-Site Feedback Form via Tooltipster
    * IS DONE ON-SITE IN COMMUNITY-LIST.JSP SINCE WE NEED THE JSON DATA
    ************************************************************************/

    $("#feedback").click(function(e) {
        if( $(".tooltipster-base").css('display') == 'none' )
        {
            $(".tooltipster-base").show();
        }
        return false;
    }).tooltipster({
        theme: 'tooltipster-light',
        speed: 0,
        contentAsHTML : true,
        position : 'bottom-right',
        autoClose : false,
        trigger: 'click',
        interactive:true,
        multiple:true,
        content: 'Loading Feedback Form ...',
        functionBefore: function(origin, continueTooltip) {
            continueTooltip();
            $.ajax({
                type: 'GET',
                url: origin[0]['href'],
                success: function(data) {
                    origin.tooltipster('content', $(data)).data('ajax', 'cached');
                }
            });
        }
    });


    /************************************************************************
    * DataTables plugin (https://www.datatables.net)
    * Finds tables in document, adds a filter input to top.
    ************************************************************************/
    $('table.with-filter').has('thead th').each(function(){
        if( $(this).find('tr').length > 1)
        {
            $(this).DataTable({
                "bSort" : false,
                'paging': false,
                'info': false,
                'stateSave': true,
                'oLanguage': {
                    'sSearch': 'Filter this table: '
                },
                'columnDefs': [{
                    'targets': '_all',
                    'defaultContent': ''
                }]
            });
        }
    });

    $('div.dataTables_filter input').removeClass('input-sm').addClass('input-md');
    $('table.dataTable').css('width', '100%');

    $('div.panel-body:not(:has(table))').each(function(index){
        $(this).next().appendTo( $(this) );
    });

    $('div.panel:not(:has(div.panel-body))').each(function(index){
        var children = $(this).children().filter(':not(div.panel-heading)');
        children.wrap('<div class="panel-body" />');
    });

    /************************************************************************
    * Select Picker Plugin (https://silviomoreto.github.io/bootstrap-select/)
    ************************************************************************/
    $('select.selectpicker').selectpicker();

    /************************************************************************
    * Community List via EasyTree
    * IS DONE ON-SITE IN COMMUNITY-LIST.JSP SINCE WE NEED THE JSON DATA
    ************************************************************************/
    /*
    $('#communityTree').easytree( {
        data: community_data,
        allowActivate: false,
        enableDnd: false,
        disableIcons: false,
        ordering: 'ordered ASC',
        slidingTime: 100,
        minOpenLevels: 0
    });
    */

    /************************************************************************
    * Show Statistics on-site the Ajax way
    * FIXME!
    ************************************************************************/
    /*
    $('#show-statistics').on('click',function(e){
        e.preventDefault();

        $.ajax({
            type: "GET",
            url: $(this).attr('href'),
            success: function(data) {
                $('#statistics').html( data );
            }
        });

    });
    */





    });

}(jQuery);
