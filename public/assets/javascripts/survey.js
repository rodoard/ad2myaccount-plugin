var surveyInit = function() {
    surveyResponse = function(surveyData) {
        msg = {
            surveyResponse:true,
            data:surveyData
        }
        sendParentMessage(msg)
    }
    $(document).on('surveyResponse', function(event, data){
        surveyResponse(data)
    })

    surveyControls =  {
        minimize: function() {
            $(".a2maonline").removeClass("full")
            $(".a2maonline").addClass("mini")
        },
        maximize: function() {
            $(".a2maonline").removeClass("mini")
                $(".a2maonline").addClass("full")

        },
        close: function() {
            sendParentMessage('close')
        }
    }
    $(".message").click(function() {
        operation = $(this).data("operation")
        surveyControls[operation]()
    })
    $('#show-next-ad').click(function(){
       showNextAd()
    })

}