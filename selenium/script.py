from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium import webdriver
import logging
import time
import json
import os


WINDOW_SIZE = "1920,1080"

if os.environ.get('CHROMEDRIVER_PATH'):
    CHROMEDRIVER_PATH = os.environ.get('CHROMEDRIVER_PATH')
else:
    CHROMEDRIVER_PATH = 'chromedriver'

chrome_options = Options()
# chrome_options.add_argument("--headless")
# chrome_options.add_argument("--window-size=%s" % WINDOW_SIZE)

driver = webdriver.Chrome(executable_path=CHROMEDRIVER_PATH,
                          options=chrome_options
                         )
logging.basicConfig(level=logging.WARNING)


def login(username, password):
    while True:
        driver.get('https://www.whizlabs.com/login/')
        driver.find_element_by_xpath('//*[@id="login"]/form[1]/div[1]/input').send_keys(username)
        driver.find_element_by_xpath('//*[@id="login"]/form[1]/div[2]/input').send_keys(password)
        driver.find_element_by_xpath('//*[@id="login"]/form[1]/button').click()
        if 'my-account' in driver.current_url:
            break



## Go to each questions
def get_question_from_quez(url):
    driver.get(url)
    output_data = [

    ]

    ul = driver.find_element_by_xpath('//*[@id="createQuizForm"]/div/div[16]/div/div/ul')
    questions = len(ul.find_elements_by_tag_name("li"))
    question_number = 1
    for question in ul.find_elements_by_tag_name("li"):
        question.click()
        question_data = {
            "question": driver.find_element_by_xpath(f"//*[@id='createQuizForm']/div/div[{question_number}]/div/div[1]/div[2]").text,
            "answers" : []
        }
        for answer in range(2, 6):
            question_data['answers'].append(driver.find_element_by_xpath(f"//*[@id='createQuizForm']/div/div[{question_number}]/div/div[1]/div[4]/div[{answer}]/label/span[2]/p").text)
        output_data.append(question_data)
        question_number = question_number + 1
    return output_data


def get_questions_from_result(url):
    driver.get(url)
    output_data = []
    total_questions = int(driver.find_element_by_xpath('//*[@id="data"]/tfoot/tr[2]/td[3]/value').text)
    range_questions = range(5, total_questions + 5)

    for question in range_questions:
        base_xpath = f"//*[@id='content-area']/div/div[2]/div[{question}]/div/div[2]"
        question_data = {
            'question' : driver.find_element_by_xpath(f"{base_xpath}/div[1]/div[2]").text
        }
        question_data["answers"] = []
        question_data["correct_answers"] = []
        
        for answer_num in range(1, 5):
            
            answer_base_xpath = f"{base_xpath}/div[2]/div[{answer_num}]/label"
            answer  = driver.find_element_by_xpath(answer_base_xpath)
                
            answer_text = driver.find_element_by_xpath(f"{answer_base_xpath}/span/p").text
            
            if 'correct-ans' in answer.get_attribute('class'):
                question_data["correct_answers"].append(answer_text)
                
            question_data["answers"].append(answer_text)
            
    output_data.append(question_data)
    return output_data

username = os.environ.get('LOGIN')
password = os.environ.get('PASSWORD')

login(username, password)

get_questions_from_result('https://www.whizlabs.com/learn/course/quiz-result/3533527')

# with open('data.json' , 'w')as file:
#     json.dump(output_data, file, indent=2)