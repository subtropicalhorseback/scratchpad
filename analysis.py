import os
import logging
import google.generativeai as genai
import datetime

logFile = "/home/opslab/Documents/geminiprompts/analysis.log"
model = genai.GenerativeModel('gemini-pro')

# Setup info logging w y-m-d_h:m in target file
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d_%H:%M',
                    handlers=[logging.FileHandler(logFile),
                              logging.StreamHandler()])


timeNow = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
update1 = f"Opening session with Gemini as of {timeNow}."
print(update1, "\n")
logging.info(update1)

# get api key from env var
def getKey():

    # pull key from env
    api_key = os.getenv('GOOGLE_API_KEY')

    # if it doesn't exist, log and raise error
    if not api_key:
        logging.error("GOOGLE_API_KEY environment variable is not set.")
        raise ValueError("Please set the 'GOOGLE_API_KEY' environment variable.")
    
    # report and log success
    else:
        timeNow = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
        update2 = f"Successfully retrieved your API key from environmental variable at {timeNow}."
        print(update2)
        logging.info(update2)

    # config api requests w api key from env
    genai.configure(api_key=api_key)

# build country-specific prompt from text file
def buildPrompt(mode):
    # pull in country var
    global country

    # here's the current path for mode-specific prompts
    promptPath = f"/home/opslab/Documents/geminiprompts/mode{mode}prompt.txt"

    if mode == ['1', '2']:
        # try to build a prompt
        try:
            with open(promptPath, 'r', encoding='utf-8') as file:

                # use the country name in the prompt
                prompt = file.read().replace("[Target Nation]", country)

                # log what we're doing
                timeNow = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
                update3 = f"Loaded prompt for mode {mode} targeting {country} as of {timeNow}."
                print(update3, "\n")
                logging.info(update3)

                return prompt
    
        # missing prompt text file
        except FileNotFoundError:
            logging.error(f"Prompt file for mode {mode} not found.")
            return None

    elif mode == '3':
        try:
            # Read base prompt for mode 3
            with open(promptPath, 'r', encoding='utf-8') as file:
                base_prompt = file.read().replace("[Target Nation]", country)

            # Initialize additional context string
            additional_context = "\n\nAdditional Context from Previous Modes:\n"
        
            # Construct file paths for mode 1 and mode 2
            mode1_path = f"/home/opslab/Documents/scratchpad/{country}_Mode1.txt"
            mode2_path = f"/home/opslab/Documents/scratchpad/{country}_Mode2.txt"
        
            # Try reading mode 1 file
            try:
                with open(mode1_path, 'r', encoding='utf-8') as mode1_file:
                    mode1_content = mode1_file.read()
                    additional_context += "\n\nMode 1 Analysis:\n" + mode1_content
            except FileNotFoundError:
                logging.warning(f"File for Mode 1 analysis of {country} not found.")
        
            # Try reading mode 2 file
            try:
                with open(mode2_path, 'r', encoding='utf-8') as mode2_file:
                    mode2_content = mode2_file.read()
                    additional_context += "\n\nMode 2 Analysis:\n" + mode2_content
            except FileNotFoundError:
                logging.warning(f"File for Mode 2 analysis of {country} not found.")
        
            # Concatenate the base prompt with additional context
            final_prompt = base_prompt + additional_context
        
            # Log the operation
            timeNow = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
            update4 = f"Loaded combined prompt for Mode 3 targeting {country} as of {timeNow}."
            print(update4, "\n")
            logging.info(update4)
        
            return final_prompt
    
        except Exception as e:
            logging.error(f"Error in building prompt for mode 3: {e}")
            return None
    

def query(model, prompt, mode):
    try:
        response = model.generate_content(prompt, stream=True) 
        full_response = "\n".join(chunk.text for chunk in response)
        logging.info("Gemini response: " + full_response)

        # File Writing for mode output
        outPath = f"/home/opslab/Documents/scratchpad/{country}_Mode{mode}.txt"

        with open(outPath, "w", encoding="utf-8") as outFile:
            outFile.write(full_response) 

        timeNow = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
        update5 = f"API response saved to file {outPath} as of {timeNow}."
        print(update5, "\n")
        logging.info(update5)

        return full_response

    # General error handling    
    except Exception as e:  
        logging.error(f"API error: {e}")
        return "An error occurred during the API call."

def start_mode_analysis(mode, prompt):
    """Initializes a chat session for a given mode of analysis with a prompt."""
    model = genai.GenerativeModel('gemini-pro')
    chat = model.start_chat(history=[])  
    response = chat.send_message(prompt)  
    logging.info(f"Initial response for mode {mode}:\n{response.text}")
    return chat

def refine_analysis(chat, additional_instructions):
    """Refines the analysis by sending additional instructions to the existing chat session."""
    response = chat.send_message(additional_instructions, stream=True)
    for chunk in response:
        # print(chunk.text)
        logging.info(f"Refinement chunk: {chunk.text}")

def interactive_session():
    """Runs an interactive analysis session that allows changing modes."""
    global global_country_name
    global_country_name = input("Enter the target country name: ")

    while True:
        mode = input("Enter analysis mode (1, 2, or 3), 'change country' to switch countries, or 'exit' to quit: ")
        if mode.lower() == 'exit':
            break
        elif mode.lower() == 'change country':
            global_country_name = input("Enter the target country name: ")
            continue

        log_content_for_country = read_log_for_country("/home/opslab/Documents/geminiprompts/geopolitical_analysis.log", global_country_name)
        prompt = get_prompt_from_file(mode) + "\n\n" + log_content_for_country
        if prompt:
            chat_session = start_mode_analysis(mode, prompt)
            while True:
                further_instructions = input("Enter further instructions, 'change mode' to switch modes, or 'exit' to end: ")
                if further_instructions.lower() == 'exit':
                    return  # Exits the while loop and ends the session
                elif further_instructions.lower() == 'change mode':
                    logging.info("Changing analysis mode.")
                    break  # Breaks the inner while loop and goes back to mode selection
                refine_analysis(chat_session, further_instructions)
        else:
            print("Failed to load the prompt. Exiting.")
            break

def main():
    logFile = "/home/opslab/Documents/geminiprompts/analysis.log"
    model = genai.GenerativeModel('gemini-pro')
    
    # API key func
    getKey()

    # declare country var for prompting
    global country

    # no error handling because plain text send to api
    country = input("Enter the target country name: ")

    # keep loop to do the thing
    while True:
        mode = input("Enter analysis mode (1, 2, or 3), 'country' to switch countries, or 'exit' to quit: ")
        # exit
        if mode.lower() == 'exit':
            print("Exiting session.")
            break

        # initial redefine country var
        elif mode.lower() == 'country':
            country = input("Enter the target country name: ")
            continue

        # mode selection
        elif mode in ['1', '2', '3']:

            # build country prompt from generic text file
            prompt = buildPrompt(mode) 
            
            # print("Analyzing with the following prompt:\n", prompt)

            # log the prompt - Mode, prompt, country
            logging.info(f"Sending the following prompt for Mode {mode} analysis targeting {country}: \n\n{prompt}\n\n ********** \n********** \n")

            # make the actual API call w the prompt
            response_text = query(model, prompt, mode)
            print(f"Gemini Response:\n\n ******************************************* \n{response_text}")
            

            command = input("Type 'change mode' to switch modes, 'change country' to change the target country, or 'exit' to end: ")
            if command.lower() == 'change mode':
                continue  # Allows selecting a new mode without re-prompting for the country
            elif command.lower() == 'change country':
                country = input("Enter the target country name: ")
                continue  # Allows changing the country and continuing analysis
            elif command.lower() == 'exit':
                print("Exiting session.")
                break
        else:
            print("Invalid mode selected. Please try again.")


if __name__ == "__main__":
    main()


