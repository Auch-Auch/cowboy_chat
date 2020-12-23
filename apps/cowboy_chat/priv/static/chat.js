var socket = null;

function add_message(message) {
    $('#messages').append('<p></p>').children().last().text(message);
}

function add_name(name) {
    $('#clients').append('<a></a>').children().last().text(name).addClass("item");;
}

function read_message_input() {
    return $('#message').val();
}

function read_name_input() {
    return $('#name').val();
}


function connect_to_chat() {

    socket = new WebSocket("ws://localhost:8080/ws");

    socket.onmessage = function(event) {
        data = JSON.parse(event.data)
        if ("message" in data) {
            add_message(data['message']);
        } else if ("clients" in data) {
            $(".item").remove();
            for (client in data["clients"]) {
                add_name(data["clients"][client]);
            }
        }
        
    };

    socket.onopen = function(event) {
        add_message(event.data);
    };

}

function send_message(e) {
    var message = read_message_input();
    add_message("you:  " + message);
    socket.send(JSON.stringify({"message": `${message}`}));
    $('#message').val("");
}

function send_name() {
    
    var name = read_name_input();
    socket.send(JSON.stringify({"name": `${name}`}));
    socket.send(JSON.stringify({"names": ""}));
    $('#name_button').hide(function() {
        $('#chat').show();
    });
    socket.send(JSON.stringify({"message": "New user connected"}));
    add_message("You are connected!");
}

$(window).on("beforeunload", function() {
    socket.send(JSON.stringify({"type": "User disconected"}));
    socket.send(JSON.stringify({"names": ""}));
    socket.onclose = function () {};
    socket.close();
})

$(document).ready(function() {
    connect_to_chat();
    $('#send-button').click(send_message);
    $('#send-name').click(send_name);
});