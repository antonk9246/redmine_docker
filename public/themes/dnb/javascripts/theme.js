if (window.jQuery) {
  $(window).load(function () {
    if (window.devicePixelRatio > 1) {
      var images = findImagesByRegexp("contacts_thumbnail", document);

      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        old_size = lowres.match(/\/(\d*)$/)[1];
        var highres = lowres.replace(/\/(\d*)$/, "/" + String(old_size * 2));
        images[i].src = highres;
      }

      var images = findImagesByRegexp(/gravatar.com\/avatar.*size=\d+/, document);

      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        old_size = lowres.match(/size=(\d+)/)[1];
        var highres = lowres.replace(/size=(\d+)/, "size=" + String(old_size * 2));
        images[i].src = highres;
        images[i].height = old_size;
        images[i].width = old_size;
      }

      var images = findImagesByRegexp(/\/attachments\/thumbnail\/\d+$/, document);

      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        var height = images[i].height;
        var width = images[i].width;
        var highres = lowres + "?size=" + Math.max(height, width) * 2;
        if (Math.max(height, width) > 0) {
          images[i].src = highres;
          images[i].height = height;
          images[i].width = width;
        }
      }

      // Sized thumbnails
      var images = findImagesByRegexp(/\/attachments\/thumbnail\/\d+\/\d+$/, document);
      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        var height = images[i].height;
        var width = images[i].width;
        old_size = lowres.match(/\/(\d*)$/)[1];
        var highres = lowres.replace(/\/(\d*)$/, "/" + String(old_size * 2));
        images[i].src = highres;
        if (Math.max(height, width) > 0) {
          images[i].src = highres;
          images[i].height = height;
          images[i].width = width;
        }
      }

      // People avatars
      var images = findImagesByRegexp(/people\/avatar.*size=\d+$/, document);

      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        old_size = lowres.match(/size=(\d+)$/)[1];
        var highres = lowres.replace(/size=(\d+)$/, "size=" + String(old_size * 2));
        images[i].src = highres;
      }
    }
  });
} else {
  document.observe("dom:loaded", function () {
    if (window.devicePixelRatio > 1) {
      var images = findImagesByRegexp("thumbnail", document);

      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        old_size = lowres.match(/size=(\d*)$/)[1];
        var highres = lowres.replace(/size=(\d*)$/, "size=" + String(old_size * 2));
        images[i].src = highres;
      }

      var images = findImagesByRegexp(/gravatar.com\/avatar.*size=\d+/, document);

      for (var i = 0; i < images.length; i++) {
        var lowres = images[i].src;
        old_size = lowres.match(/size=(\d+)/)[1];
        var highres = lowres.replace(/size=(\d+)/, "size=" + String(old_size * 2));
        images[i].src = highres;
        images[i].height = old_size;
        images[i].width = old_size;
      }
    }
  });
}

function findImagesByRegexp(regexp, parentNode) {
  var images = Array.prototype.slice.call((parentNode || document).getElementsByTagName("img"));
  var length = images.length;
  var ret = [];
  for (var i = 0; i < length; ++i) {
    if (images[i].src.search(regexp) != -1) {
      ret.push(images[i]);
    }
  }
  return ret;
}

//==================================================== DROPDOWN NAVIGATION ========================================================/

// $(document).ready(function () {
//   $('<li class="dropdown-menu-button"><div class= "dropdown-menu"></div></li > ').insertAfter($("#top-menu > ul li:last-of-type"));

//   $("#top-menu .all-files, #top-menu .books, #top-menu .knowledgebase, #top-menu .questions").parent().appendTo($("#top-menu .dropdown-menu"));
// });

$(document).ready(function () {
  $('<li class="profile-menu"><div class= "account-menu"><//div></li >').insertAfter($("#account > ul li:last-of-type"));

  $(".my-account, .logout").parent().appendTo($("#top-menu .account-menu"));
});

// ==================================================== FLYOUT MENU ================================================================

$(document).ready(function () {
  $("#header .mobile-toggle-button").prependTo("#wrapper");
});

$(document).ready(function () {
  $(document.body).append('<div id="overlay"></div>');
});

// ===================================================== PROJECTS & localStorage =============================================================

$(document).ready(function () {
  if (!localStorage.projects) {
    localStorage.setItem("projects", JSON.stringify([]));
  }

  var arr = JSON.parse(localStorage.projects);

  $('<div class="description_btn"></div > ').insertBefore($("#projects-index ul li div.child .wiki.description"));
  $('<div class="subprojects_btn"></div > ').insertBefore($("#projects-index > ul.projects.root > li.root > ul.projects > li.child > ul.projects").prev());

  arr.forEach(function (e) {
    var id = document.getElementById(e);
    var btn = id?.querySelector(".subprojects_btn");
    btn ||= id?.querySelector(".description_btn");

    if ($(btn).attr("class") == "description_btn") {
      $(btn).next().slideToggle(0);
    } else if ($(btn).attr("class") == "subprojects_btn") {
      $(btn).next().next().slideToggle(0);
    }
  });

  $(".description_btn").click(function () {
    $(this).next().slideToggle(0);

    const project_id = $(this).closest("li").attr("id");

    if (!arr.includes(project_id)) {
      arr.push(project_id);
    } else {
      arr.splice(arr.indexOf(project_id), 1);
    }

    localStorage.setItem("projects", JSON.stringify(arr));

    return false;
  });

  $(".subprojects_btn").click(function () {
    $(this).next().next().slideToggle(0);

    const project_id = $(this).closest("li").attr("id");

    if (!arr.includes(project_id)) {
      arr.push(project_id);
    } else {
      arr.splice(arr.indexOf(project_id), 1);
    }

    localStorage.setItem("projects", JSON.stringify(arr));

    return false;
  });
});

// ======================================================= SIDEBAR ===========================================================

$(document).ready(function () {
  $("#sidebar > a, #sidebar > br ").insertAfter($("#sidebar > ul:first()"));
});

// ================================================== FIELDSET FILTERS ====================================================

$(document).ready(function () {
  if (!$("#filters").hasClass("collapsed")) {
    $("#filters").addClass("collapsed");
    $("#filters > div").attr("style", "display:none");
  }
});
