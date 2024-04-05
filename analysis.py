import os
import logging
import google.generativeai as genai

# Setup logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    handlers=[logging.FileHandler("/home/opslab/Documents/geminiprompts/geopolitical_analysis.log"),
                              logging.StreamHandler()])

def configure_api():
    """Configures the API with the user's API key."""
    api_key = os.getenv('GOOGLE_API_KEY')
    if not api_key:
        logging.error("GOOGLE_API_KEY environment variable is not set.")
        raise ValueError("Please set the 'GOOGLE_API_KEY' environment variable.")
    genai.configure(api_key=api_key)

def get_prompt_from_file(mode):
    """Reads the prompt from a file and replaces placeholder with the target country.""" 
    global global_country_name
    prompt_path = f"/home/opslab/Documents/geminiprompts/mode{mode}prompt.txt"
    try:
        with open(prompt_path, 'r', encoding='utf-8') as file:
            prompt = file.read().replace("[Target Nation]", global_country_name)
            logging.info(f"Loaded prompt for mode {mode} targeting {global_country_name}.")
            return prompt
    except FileNotFoundError:
        logging.error(f"Prompt file for mode {mode} not found.")
        return None

def read_log_for_country(log_file_path, country_name):
    """Extracts log entries for a specific country from the log file."""
    try:
        with open(log_file_path, 'r', encoding='utf-8') as log_file:
            relevant_entries = (line for line in log_file if country_name in line)
            return "\n".join(relevant_entries)
    except FileNotFoundError:
        logging.error(f"Log file not found at {log_file_path}.")
        return ""

def call_genai_api(prompt):
    """Makes an API call to Gemini and handles the response."""
    model = genai.GenerativeModel('gemini-pro')
    try:
        response = model.generate_content(prompt, stream=True) 
        full_response = "\n".join(chunk.text for chunk in response)
        logging.info("Full API response: " + full_response)
        return full_response
    except Exception as e:  # General error handling
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
    global global_country_name

    configure_api()
    global_country_name = input("Enter the target country name: ")

    while True:
        mode = input("Enter analysis mode (1, 2, or 3), 'change country' to switch countries, or 'exit' to quit: ")
        if mode.lower() == 'exit':
            print("Exiting session.")
            break
        elif mode.lower() == 'change country':
            global_country_name = input("Enter the target country name: ")
            continue

        if mode in ['1', '2', '3']:
            prompt = get_prompt_from_file(mode) 
            
            #if mode == '3':
                # For Mode 3, append log content to provide context
            #    prompt += "\n\n" + "Additional Context from Previous Modes:\n" + read_log_for_country("/home/opslab/Documents/geminiprompts/geopolitical_analysis.log", global_country_name)

            # print("Analyzing with the following prompt:\n", prompt)
            logging.info(f"Sending the following prompt for Mode {mode} analysis targeting {global_country_name}: {prompt}")

            response_text = call_genai_api(prompt)  # Make the actual API call
            print(f"Full API Response:\n\n ******************************************* \n{response_text}")

            command = input("Type 'change mode' to switch modes, 'change country' to change the target country, or 'exit' to end: ")
            if command.lower() == 'change mode':
                continue  # Allows selecting a new mode without re-prompting for the country
            elif command.lower() == 'change country':
                global_country_name = input("Enter the target country name: ")
                continue  # Allows changing the country and continuing analysis
            elif command.lower() == 'exit':
                print("Exiting session.")
                break
        else:
            print("Invalid mode selected. Please try again.")


if __name__ == "__main__":
    main()


