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

    # Correctly check if mode is '1' or '2'
    if mode in ['1', '2']:
        # here's the current path for mode-specific prompts
        promptPath = f"/home/opslab/Documents/geminiprompts/mode{mode}prompt.txt"

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
            mode1_path = f"/home/opslab/Documents/geminiprompts/output/{country}_Mode1.txt"
            mode2_path = f"/home/opslab/Documents/geminiprompts/output/{country}_Mode2.txt"
        
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
    
def interactive_analysis_with_history(model, initial_mode, initial_prompt):
    """
    Starts an interactive analysis session with history,
    allowing for iterative refinements and feedback.
    
    :param model: The generative model instance.
    :param initial_mode: The initial mode of analysis.
    :param initial_prompt: The initial prompt for the session.
    """
    try:
        # Start the chat session 
        chat = model.start_chat() 
        history = []  # Initialize an empty history list 

        # Send the initial prompt
        response = chat.send_message(initial_prompt)
        log_and_save_response(initial_mode, response.text, "Initial")

        while True:
            # User input for further instructions or to exit
            additional_instructions = input("Enter further instructions, 'exit' to end, or 'save' to save current chat: ").strip()
            
            if additional_instructions.lower() == 'exit':
                print("Exiting session.")
                break

            elif additional_instructions.lower() == 'save':
                # Save the current chat history
                save_chat_history(history, initial_mode)
                print("Chat history saved.")

            else:
                # Send additional instructions and log responses
                response = chat.send_message(additional_instructions, stream=True)

                for chunk in response:
                    history.append({'role': 'User', 'parts': [{'text': additional_instructions}]})
                    history.append({'role': 'Model', 'parts': [{'text': chunk.text}]}) 
                
                    log_and_save_response(initial_mode, chunk.text, "Refinement")

    except Exception as e:
        logging.error(f"Interactive analysis error: {e}")
        print("An error occurred during the interactive analysis.")

def log_and_save_response(mode, response_text, stage):
    """
    Logs and saves the response text to a file.
    
    :param mode: The mode of analysis.
    :param response_text: The text to log and save.
    :param stage: The stage of interaction ('Initial' or 'Refinement').
    """
    if isinstance(response_text, genai.types.generation_types.GenerateContentResponse):
        # Extract text from the first candidate
        response_text = response_text.result.candidates[0].content.parts[0].text

    logging.info(f"{stage} response for mode {mode}:\n{response_text}")

    # Define the output path based on stage and mode
    outPath = f"/home/opslab/Documents/geminiprompts/output/{country}_Mode{mode}_{stage}.txt"
    with open(outPath, "w", encoding="utf-8") as outFile:
        outFile.write(response_text)

    timeNow = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
    print(f"{stage} response saved to file {outPath} as of {timeNow}.")

def save_chat_history(history, mode):
    """
    Saves the entire chat history to a file for review.

    :param history: The chat history to save.
    :param mode: The analysis mode for naming the file.
    """
    historyPath = f"/home/opslab/Documents/geminiprompts/output/{country}_Mode{mode}_ChatHistory.txt"
    with open(historyPath, "w", encoding="utf-8") as historyFile:
        for entry in history: 
            if 'parts' in entry:
                historyFile.write(f"{entry['role'].title()}: {entry['parts'][0]['text']}\n") 
            else:
                historyFile.write(f"{entry['role'].title()}: {entry['text']}\n")

def main():
    model = genai.GenerativeModel('gemini-pro')

    # Declare country var for prompting
    global country

    # Retrieve the API key and configure the model
    getKey()
    
    # Initialize session
    print("Enter the target country name: ")
    country = input().strip()

    while True:
        print("Enter analysis mode (1, 2, or 3), 'country' to switch countries, or 'exit' to quit: ")
        mode = input().strip().lower()
        
        # Exit condition
        if mode == 'exit':
            print("Exiting session.")
            break
        
        # Option to redefine country
        elif mode == 'country':
            print("Enter the target country name: ")
            country = input().strip()
            continue

        # Handling valid modes
        elif mode in ['1', '2', '3']:
            # Build the initial prompt based on the mode
            prompt = buildPrompt(mode)
            if prompt:
                # Log the prompt
                logging.info(f"Initiating analysis for Mode {mode} targeting {country} with the following prompt:\n{prompt}")
                # Start the interactive session
                interactive_analysis_with_history(model, mode, prompt)
            else:
                print("Failed to build prompt. Please check the input and try again.")
        else:
            print("Invalid mode selected. Please try again.")

if __name__ == "__main__":
    main()