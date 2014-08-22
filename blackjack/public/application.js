$(document).ready(function(){

  $("form#name").submit(function(e){
      if($('#text_field').val() ==  "") {
      e.preventDefault();
    alert("Please enter your name.");
      }
  });
});



// function player_hit() {
//   $(document).on('click', '#player_hit input', function() {
//     $.ajax({
//       type: 'POST',
//       url: '/hit_or_stay'
//     }).done(function(msg) {
//       $('#game').replaceWith(msg);
//     });
//     return false;
//   });
// }

// function player_stay() {
//   $(document).on('click', '#player_stay input', function() {
//     $.ajax({
//       type: 'POST',
//       url: '/hit_or_stay'
//     }).done(function(msg) {
//       $('#game').replaceWith(msg);
//     });
//     return false;
//   });
// }

// function dealer_hit() {
//   $(document).on('click', '#dealer_turn input', function() {
//     $.ajax({
//       type: 'POST',
//       url: '/dealer_turn'
//     }).done(function(msg) {
//       $('#game').replaceWith(msg);
//     });
//     return false;
//   });
// }
