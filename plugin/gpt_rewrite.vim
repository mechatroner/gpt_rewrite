command! -range GptConvert call GptConvertFunction(<line1>, <line2>)

function! GptConvertFunction(line1, line2)
    let selected_text = getline(a:line1, a:line2)

    let text_to_convert = join(selected_text, "\n")

    if !exists('g:openai_api_key') || empty('g:openai_api_key')
	    echoerr 'g:openai_api_key is undefined'
        return
    endif

    " The code was influenced by bobobocode/VimChatGPT
    let api_key = g:openai_api_key

    let prompt = text_to_convert
    let completion_model = 'code-davinci-002'
    let chat_model = ''
    if exists('g:openai_completion_model') && !empty('g:openai_completion_model')
        let completion_model = g:openai_completion_model
        let chat_model = ''
    endif
    if exists('g:openai_chat_model') && !empty('g:openai_chat_model')
        let completion_model = ''
        let chat_model = g:openai_chat_model
    endif

    let payload = ""
    let url = ""
    if chat_model != ""
        let url = 'https://api.openai.com/v1/chat/completions'
        let payload = '{"temperature": 0, "max_tokens": 512, "model": "' . chat_model . '", "messages": [{"role": "user", "content": ' . json_encode(prompt) . '}]}'
    else
        let url = 'https://api.openai.com/v1/completions'
        let payload = '{"temperature": 0, "presence_penalty": 0.3, "max_tokens": 512, "model": "' . completion_model . '", "prompt": ' . json_encode(prompt) . '}'
    endif

    let response = system('curl --connect-timeout 10 -s -H "Content-Type: application/json" -H "Authorization: Bearer ' . api_key . '" -d ' . shellescape(payload) . ' ' . url)
    echomsg response
	if v:shell_error
	    echoerr 'Curl command failed: ' + response
        return
	endif
    let json_response = json_decode(response)
    if completion_model != "" && has_key(json_response, 'choices') && len(json_response['choices']) > 0 && has_key(json_response['choices'][0], 'text')
        let text_completion = json_response['choices'][0]['text']
        call append(a:line2, split(text_completion, "\n"))
        call cursor(a:line2, 1)
    elseif chat_model != "" && has_key(json_response, 'choices') && len(json_response['choices']) > 0 && has_key(json_response['choices'][0], 'message')
        let text_completion = json_response['choices'][0]['message']['content']
        call append(a:line2, split(text_completion, "\n"))
        call cursor(a:line2, 1)
    elseif has_key(json_response, 'error')
        let error_msg = json_response['error']['message']
	    echoerr 'Gpt returned an error: ' + error_msg
        return
    else
	    echoerr 'Something went wrong. Gpt response: "' . response . '"'
        return
    endif
endfunction
