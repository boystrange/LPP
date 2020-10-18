$(document).ready(function() {
    $('.solution').each(function(i) {
        // find the code section and read its id
        var currentId = "solution" + (i + 1);
        $(this).attr('id', currentId);

        // now create the button, setting the clipboard target to the id
        var btn = document.createElement('button');
        btn.setAttribute('type', 'btn');
	btn.setAttribute('class', 'btn btn--inverse btn--small')
	btn.setAttribute('onclick', '$("#' + currentId + '").toggle(200);')
        btn.innerHTML = 'Soluzione';
        this.parentNode.insertBefore(btn, this);
    });
});
